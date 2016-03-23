module RailsNewsfeed
  class Activity
    attr_accessor :id
    attr_accessor :content
    attr_accessor :object
    attr_accessor :time
    attr_reader :new_record

    # gets table name
    def self.table_name
      'activity'
    end

    # gets index table name
    def self.index_table_name
      "#{table_name}_index"
    end

    # gets schema
    # DO NOT override this method unless you know what you are doing
    def self.schema
      { id: :uuid, content: :text, time: :timestamp, object: :text }
    end

    # finds activity by id
    def self.find(id)
      r = Connection.select(table_name, schema, '*', { id: id }, page_size: 1).first
      return nil unless r
      create_from_cass_act(r)
    end

    # hides all feeds of object
    def self.hide_all_of(object)
      return true unless object
      Connection.select(index_table_name, schema, '*', object: object).each do |r|
        id = r['id'].to_s
        Connection.delete(table_name, schema, id: id)
        delete_from_feed(id)
      end
      true
    end

    # deletes from all feed tables
    def self.delete_from_feed(id, last = nil)
      cqls = []
      FeedTable.all.each do |i|
        i_tbl = i.class.table_name
        i_schema = i.class.schema
        Connection.select(i_tbl, i_schema, '*', { activity_id: id }, filtering: true).each do |r|
          cqls.push(Connection.delete(i_tbl, i_schema, { id: r['id'], activity_id: r['activity_id'].to_s }, true))
          next unless last
          cqls.push(Connection.insert(i_tbl, i_schema, NewsfeedModel.from_cass_act(r['id'], last), true))
        end
      end
      Connection.batch_cqls(cqls.uniq) unless cqls.empty?
      true
    end

    # deletes an activity by id including activities from feed tables
    def self.delete(id, show_last = true)
      act = find(id)
      return true unless act
      act.delete(show_last)
    end

    # creates from feed cassandra
    def self.create_from_cass_feed(res)
      new(from_cass(:feed, res))
    end

    # creates from activity cassandra
    def self.create_from_cass_act(res)
      new(from_cass(:act, res))
    end

    # gets hash from cassandra
    def self.from_cass(type, res)
      if type == :act
        id = res['id'].to_s
        content = res['content']
        object = res['object']
        time = res['time']
      else
        id = res['activity_id'].to_s
        content = res['activity_content']
        object = res['activity_object']
        time = res['activity_time']
      end
      { id: id, content: content, time: time, object: object, new_record: false }
    end

    # initializes
    def initialize(options = {})
      @id = options.key?(:id) ? options[:id] : Cassandra::Uuid::Generator.new.now.to_s
      @content = options.key?(:content) ? options[:content] : nil
      @object = options.key?(:object) ? options[:object] : nil
      @time = options.key?(:time) ? options[:time] : DateTime.current.strftime('%Y-%m-%d %H:%M:%S%z')
      @new_record = options.key?(:new_record) ? options[:new_record] : true
    end

    # saves
    def save
      return insert if @new_record
      update
    end

    # deletes including activities from feed tables
    def delete(show_last = true)
      return false if @new_record
      return false unless Connection.delete(self.class.table_name, self.class.schema, id: @id)
      l = nil
      if @object
        Connection.delete(self.class.index_table_name, self.class.schema, object: @object, id: @id)
        l = Connection.select(self.class.index_table_name, self.class.schema, '*', object: @object).first if show_last
      end
      self.class.delete_from_feed(@id, l)
    end

    # converts to hash
    def to_h
      { id: @id, content: @content, time: @time, object: @object }
    end

    protected

      # inserts
      def insert
        return false unless Connection.insert(self.class.table_name, self.class.schema, to_h)
        unless @object.nil?
          unless Connection.insert(self.class.index_table_name, self.class.schema, to_h)
            Connection.delete(self.class.table_name, self.class.schema, id: @id)
            return false
          end
        end
        @new_record = false
        true
      end

      # updates
      def update
        Connection.update(self.class.table_name, self.class.schema, { id: @id }, to_h)
      end
  end
end
