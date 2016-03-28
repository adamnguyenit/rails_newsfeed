module RailsNewsfeed
  class Activity
    attr_reader :id
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
      { id: :uuid, content: :text, object: :text, time: :timestamp }
    end

    # gets all activities
    def self.all(opt = {})
      rs = Connection.select(table_name, schema, '*') if opt.empty?
      rs = Connection.select(index_table_name, schema, '*', object: opt[:object]) if opt.key?(:object)
      acts = []
      rs.each { |r| acts.push(create_from_cass(:act, r)) } if rs
      acts
    end

    # creates activity
    def self.create(opt = {})
      act = new(opt)
      return nil unless act.save
      act
    end

    # creates without failling
    def self.create!(opt = {})
      create(opt)
    rescue
      nil
    end

    # finds activity by id
    def self.find(id)
      r = Connection.select(table_name, schema, '*', { id: id }, page_size: 1).first
      return nil unless r
      create_from_cass(:act, r)
    end

    # finds without failling
    def self.find!(id)
      find(id)
    rescue
      nil
    end

    # deletes activities
    def self.delete(opt = {}, show_last = true)
      if opt.key?(:id)
        act = find(opt[:id])
        return true unless act
        return act.delete(show_last)
      elsif opt.key?(:object)
        all(object: opt[:object]).each { |a| a.delete(false) }
        return true
      else
        # truncates activity table and feed tables
        Connection.exec_cql("TRUNCATE #{table_name}")
        Connection.exec_cql("TRUNCATE #{index_table_name}")
        FeedTable.all.each { |r| Connection.exec_cql("TRUNCATE #{r.class.table_name}") }
        return true
      end
    end

    # deletes without failling
    def self.delete!(opt = {}, show_last = true)
      delete(opt, show_last)
    rescue
      false
    end

    # creates from feed cassandra
    def self.create_from_cass(type, res)
      h = {}
      temp = type == :act ? '' : 'activity_'
      schema.keys.each do |k|
        key = "#{temp}#{k}"
        val = k == :id || k == :time ? res[key].to_s : res[key]
        h[k] = val
      end
      h[:new_record] = false
      new(h)
    end

    # initializes
    def initialize(options = {})
      @id = options.key?(:id) ? options[:id] : nil
      @content = options.key?(:content) ? options[:content] : nil
      @object = options.key?(:object) ? options[:object] : nil
      @time = options.key?(:time) ? options[:time] : nil
      @new_record = options.key?(:new_record) ? options[:new_record] : true
    end

    # saves
    def save
      return insert if @new_record
      update
    end

    # saves without failling
    def save!
      save
    rescue
      false
    end

    # deletes including activities from feed tables
    def delete(show_last = true)
      return false if @new_record
      Connection.delete(self.class.table_name, self.class.schema, id: @id)
      Connection.delete(self.class.index_table_name, self.class.schema, object: @object, id: @id) if @object
      return delete_from_feed(@id, nil) unless show_last
      delete_from_feed(@id, last)
    end

    # deletes without failling
    def delete!(show_last = true)
      delete(show_last)
    rescue
      false
    end

    # converts to hash
    def to_h(prefix = nil)
      { "#{prefix}id".to_sym => @id, "#{prefix}content".to_sym => @content,
        "#{prefix}object".to_sym => @object, "#{prefix}time".to_sym => @time }
    end

    protected

      # inserts
      def insert
        return false unless @content
        @id ||= Cassandra::Uuid::Generator.new.now.to_s
        @time ||= Cassandra::Types::Timestamp.new(DateTime.current).to_s
        Connection.insert(self.class.table_name, self.class.schema, to_h)
        Connection.insert(self.class.index_table_name, self.class.schema, to_h) unless @object.nil?
        @new_record = false
        true
      end

      # updates
      def update
        Connection.update(self.class.table_name, self.class.schema, { id: @id }, to_h)
        # updates from all feed models
        cqls = []
        FeedTable.all.each do |i|
          i_tbl = i.class.table_name
          i_schema = i.class.schema
          Connection.select(i_tbl, i_schema, '*', { activity_id: @id }, filtering: true).each do |r|
            cqls.push(Connection.update(i_tbl, i_schema, { id: r['id'], activity_id: @id }, to_h('activity_'), true))
          end
        end
        Connection.batch_cqls(cqls)
        true
      end

      # deletes from all feed tables
      def delete_from_feed(id, last = nil)
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
        Connection.batch_cqls(cqls.uniq)
        true
      end

      # gets last activity of object
      def last
        return nil unless @object
        Connection.select(self.class.index_table_name, self.class.schema, '*', object: @object).first
      end
  end
end
