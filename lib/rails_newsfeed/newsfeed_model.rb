module RailsNewsfeed
  class NewsfeedModel
    SALT_KEY = 'fQEEumGosuS92VcVVMPm'.freeze
    SECRET_KEY = 'sL6PySf7Ijo8L0ZhU7R2'.freeze

    class_attribute :id_type, instance_writer: false
    self.id_type = :bigint

    attr_reader :id
    attr_reader :next_page_token

    # sets type of id
    def self.type_of_id(type)
      self.id_type = type
    end

    # gets table name
    def self.table_name
      name.demodulize.underscore
    end

    # gets schema
    # DO NOT override this method unless you know what you are doing
    def self.schema
      { id: id_type, activity_id: :uuid, activity_content: :text, activity_object: :text, activity_time: :timestamp }
    end

    # initializes
    def initialize(options = {})
      @id = nil
      @next_page_token = nil
      @id = options[:id] if options.key?(:id)
      @next_page_token = options[:next_page_token] if options[:next_page_token]
    end

    # inserts an activity into table
    def insert(activity, related = true, hide_old = true)
      record = { id: @id, activity_id: activity.id, activity_content: activity.content,
                 activity_object: activity.object, activity_time: activity.time }
      return false unless Connection.insert(self.class.table_name, self.class.schema, record)
      ins_arr = []
      ins_arr.push(self) if hide_old
      cqls = []
      rl = Relation.related_of(self)
      if related
        rl.each do |ins|
          record[:id] = ins.id
          cqls.push(Connection.insert(ins.class.table_name, ins.class.schema, record, true))
          ins_arr.push(ins) if hide_old
        end
        cqls.uniq
        ins_arr.uniq
      end
      cqls |= cql_hide_old_feeds_of(activity, ins_arr) if hide_old && !ins_arr.empty?
      Connection.batch_cqls(cqls) unless cqls.empty?
      true
    end

    # deletes an activity from table
    def delete(activity_id)
      Connection.delete(self.class.table_name, self.class.schema, id: @id, activity_id: activity_id)
    end

    # gets feeds
    def feeds(page_size = 10)
      @feeds = []
      options = { page_size: page_size.to_i }
      options[:paging_state] = decoded_next_page_token if @next_page_token
      result = Connection.select(self.class.table_name, self.class.schema, '*', { id: @id }, options)
      result.each do |r|
        n = {
          id: r['activity_id'].to_s,
          content: r['activity_content'],
          object: r['activity_object'],
          time: r['activity_time'],
          new_record: false }
        @feeds.push(Activity.new(n))
      end
      encoded_next_page_token(result)
      after_feeds
      @feeds
    end

    # overrides this method to implement your own
    def after_feeds
    end

    # registers to another
    def register(to, options = {})
      Relation.create(self, to, options)
    end

    # deregisters to another
    def deregister(to, options = {})
      Relation.delete(self, to, options)
    end

    # checks related
    def register?(to)
      Relation.related?(self, to)
    end

    protected

      # encodes next_page_token
      def encoded_next_page_token(result)
        if result.nil? || result.last_page?
          @next_page_token = nil
        else
          key = ActiveSupport::KeyGenerator.new(SECRET_KEY).generate_key(SALT_KEY)
          @next_page_token = ActiveSupport::MessageEncryptor.new(key).encrypt_and_sign(result.paging_state)
        end
        @next_page_token
      end

      # decodes next_page_token
      def decoded_next_page_token
        key = ActiveSupport::KeyGenerator.new(SECRET_KEY).generate_key(SALT_KEY)
        ActiveSupport::MessageEncryptor.new(key).decrypt_and_verify(@next_page_token)
      end

      # generates cqls to hide old feeds
      def cql_hide_old_feeds_of(activity, ins_arr)
        return [] unless activity.object
        cqls = []
        cond = { object: activity.object }
        Connection.select(activity.class.index_table_name, activity.class.schema, '*', cond).each do |r|
          id = r['id'].to_s
          next if id == activity.id
          ins_arr.each do |t|
            cond = { id: t.id, activity_id: id }
            cqls.push(Connection.delete(t.class.table_name, t.class.schema, cond, true))
          end
        end
        cqls.uniq
      end
  end
end