CREATE KEYSPACE rails_newsfeed_test WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor': 3 };
USE rails_newsfeed_test;
CREATE TABLE activity (id uuid, content text, time timestamp, object text, PRIMARY KEY (id));
CREATE TABLE activity_index (id uuid, content text, time timestamp, object text, PRIMARY KEY ((object), id));
CREATE TABLE feed_table (table_class text, PRIMARY KEY (table_class));
CREATE TABLE relation (id uuid, from_class text, from_id text, to_class text, to_id text, PRIMARY KEY ((from_class, from_id), id));
CREATE TABLE relation_index(id uuid, from_class text, from_id text, to_class text, to_id text, PRIMARY KEY ((from_class, from_id, to_class, to_id)));
CREATE TABLE user_feed (id bigint, activity_id uuid, activity_content text, activity_object text, activity_time timestamp, PRIMARY KEY ((id), activity_id));
INSERT INTO feed_table (table_class) VALUES ('UserFeed');
