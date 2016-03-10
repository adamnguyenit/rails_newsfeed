module RailsNewsfeed
  class FeedTable
    # gets table name
    def self.table_name
      'feed_table'
    end

    # gets schema
    # DO NOT override this method unless you know what you are doing
    def self.schema
      { table_class: :text }
    end

    # adds table
    def self.create(tbl_class)
      Connection.insert(table_name, schema, table_class: tbl_class)
    end

    # removes table
    def self.delete(tbl_class)
      Connection.delete(table_name, schema, table_class: tbl_class)
    end

    # gets all feed tables
    def self.all
      items = []
      Connection.select(table_name).each do |r|
        cons = r['table_class'].safe_constantize
        next unless cons
        ins = cons.new
        items.push(ins) if ins
      end
      items
    end
  end
end
