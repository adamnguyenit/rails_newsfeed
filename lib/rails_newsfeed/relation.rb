module RailsNewsfeed
  class Relation
    # gets table name
    def self.table_name
      'relation'
    end

    # gets index table name
    def self.index_table_name
      "#{table_name}_index"
    end

    # gets schema
    # DO NOT override this method unless you know what you are doing
    def self.schema
      { id: :uuid, from_class: :text, from_id: :text, to_class: :text, to_id: :text }
    end

    # creates relations between two objects
    def self.create(from, to, options = {})
      id = Cassandra::Uuid::Generator.new.now.to_s
      record = { id: id, from_class: from.class.name, from_id: from.id, to_class: to.class.name, to_id: to.id }
      return false unless Connection.insert(table_name, schema, record)
      unless Connection.insert(index_table_name, schema, record)
        Connection.delete(table_name, schema, id: id, from_class: from.class.name, from_id: from.id)
        return false
      end
      if options[:side] == :both
        unless create(to, from)
          delete(from, to)
          return false
        end
      end
      true
    end

    # deletes relations between two objects
    def self.delete(from, to, options = {})
      cond = { from_class: from.class.name, from_id: from.id, to_class: to.class.name, to_id: to.id }
      i = Connection.select(index_table_name, schema, '*', cond).first
      if i
        Connection.delete(table_name, schema, from_class: from.class.name, from_id: from.id, id: i['id'].to_s)
        Connection.delete(index_table_name, schema, cond)
      end
      return delete(to, from) if options[:side] == :both
      true
    end

    # gets relateds of object
    def self.related_of(from)
      relateds = []
      result = Connection.select(table_name, schema, '*', from_class: from.class.name, from_id: from.id)
      result.each do |r|
        cons = r['to_class'].safe_constantize
        next unless cons
        ins = cons.new(id: r['to_id'])
        relateds.push(ins) if ins
      end
      relateds
    end

    # checks is related
    def self.related?(from, to)
      cond = { from_class: from.class.name, from_id: from.id, to_class: to.class.name, to_id: to.id }
      i = Connection.select(index_table_name, schema, '*', cond).first
      return false unless i
      cond = { from_class: from.class.name, from_id: from.id, id: i['id'].to_s }
      return false unless Connection.select(table_name, schema, '*', cond)
      true
    end
  end
end
