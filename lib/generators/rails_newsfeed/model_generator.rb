require 'rails/generators'
require 'rails_newsfeed/feed_table'

module RailsNewsfeed
  class ModelGenerator < Rails::Generators::NamedBase
    class_option :type_of_id, type: :string, require: false
    def process
      case behavior
      when :invoke
        invoke
      when :revoke
        revoke
      end
    end

    private

      def invoke
        t = options.key?('type_of_id') ? options['type_of_id'] : 'bigint'
        RailsNewsfeed::Connection.exec_cql("DROP TABLE IF EXISTS #{file_name}")
        RailsNewsfeed::Connection.exec_cql("CREATE TABLE #{file_name}
        (id #{t}, activity_id uuid, activity_content text, activity_object text, activity_time timestamp,
        PRIMARY KEY ((id), activity_id))")
        RailsNewsfeed::Connection.exec_cql("INSERT INTO #{RailsNewsfeed::FeedTable.table_name} (table_class)
        VALUES ('#{class_name}')")
        create_file "app/models/#{file_name}.rb", <<-FILE
  class #{class_name} < RailsNewsfeed::NewsfeedModel
    type_of_id :#{t}
  end
      FILE
      end

      def revoke
        RailsNewsfeed::Connection.exec_cql("DROP TABLE IF EXISTS #{file_name}")
        RailsNewsfeed::Connection.exec_cql("DELETE FROM #{RailsNewsfeed::FeedTable.table_name}
        WHERE table_class='#{class_name}'")
        @behavior = :invoke
        remove_file "app/models/#{file_name}.rb"
      end
  end
end
