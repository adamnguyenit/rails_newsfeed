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
      new(id: r['id'].to_s, content: r['content'], time: r['time'], object: r['object'], new_record: false)
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
          n = { id: r['id'], activity_id: last['id'].to_s, activity_content: last['content'],
                activity_object: last['object'], activity_time: last['time'].to_s }
          cqls.push(Connection.insert(i_tbl, i_schema, n, true))
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

    # initializes
    def initialize(options = {})
      @id = Cassandra::Uuid::Generator.new.now.to_s
      @content = nil
      @object = nil
      @time = DateTime.current.strftime('%Y-%m-%d %H:%M:%S%z')
      @new_record = true
      @content = options[:content] if options.key?(:content)
      @content = nil if @content == ''
      @time = options[:time] if options.key?(:time)
      @id = options[:id] if options.key?(:id)
      @object = options[:object] if options.key?(:object)
      @object = nil if @object == ''
      @new_record = options[:new_record] if options.key?(:new_record)
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
