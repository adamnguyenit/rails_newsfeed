require 'rails/generators'
require 'rails_newsfeed/connection'
require 'rails_newsfeed/activity'
require 'rails_newsfeed/feed_table'
require 'rails_newsfeed/relation'

module RailsNewsfeed
  class InitGenerator < Rails::Generators::Base
    desc 'This generator initials your cassandra schema db for feed'
    def process
      cfg = RailsNewsfeed::Connection.config
      connection = Cassandra.cluster(cfg || {}).connect('system')
      connection.execute("DROP KEYSPACE IF EXISTS #{cfg['keyspace']}")
      connection.execute("CREATE KEYSPACE #{cfg['keyspace']}
      WITH REPLICATION={ 'class': 'SimpleStrategy', 'replication_factor': 3 }")
      connection.execute("USE #{cfg['keyspace']}")
      connection.execute("CREATE TABLE #{RailsNewsfeed::Activity.table_name}
      (id uuid, content text, time timestamp, object text, PRIMARY KEY (id))")
      connection.execute("CREATE TABLE #{RailsNewsfeed::Activity.index_table_name}
      (id uuid, content text, time timestamp, object text, PRIMARY KEY ((object), id))")
      connection.execute("CREATE TABLE #{RailsNewsfeed::FeedTable.table_name}
      (table_class text, PRIMARY KEY (table_class))")
      connection.execute("CREATE TABLE #{RailsNewsfeed::Relation.table_name}
      (id uuid, from_class text, from_id text, to_class text, to_id text, PRIMARY KEY ((from_class, from_id), id))")
      connection.execute("CREATE TABLE #{RailsNewsfeed::Relation.index_table_name}
      (id uuid, from_class text, from_id text, to_class text, to_id text,
      PRIMARY KEY ((from_class, from_id, to_class, to_id)))")
    end
  end
end
