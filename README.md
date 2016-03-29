# Newsfeed for Rails
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/adamnguyenit/rails_newsfeed/master/LICENSE)
[![Build Status](https://travis-ci.org/adamnguyenit/rails_newsfeed.svg?branch=master)](https://travis-ci.org/adamnguyenit/rails_newsfeed)
[![Dependency Status](https://gemnasium.com/adamnguyenit/rails_newsfeed.svg)](https://gemnasium.com/adamnguyenit/rails_newsfeed)
[![Code Climate](https://codeclimate.com/github/adamnguyenit/rails_newsfeed/badges/gpa.svg)](https://codeclimate.com/github/adamnguyenit/rails_newsfeed)
[![Coverage Status](https://coveralls.io/repos/github/adamnguyenit/rails_newsfeed/badge.svg?branch=master)](https://coveralls.io/github/adamnguyenit/rails_newsfeed?branch=master)
[![Gem Version](https://badge.fury.io/rb/rails_newsfeed.svg)](https://badge.fury.io/rb/rails_newsfeed)
![Download](http://ruby-gem-downloads-badge.herokuapp.com/rails_newsfeed)
[![GitHub stars](https://img.shields.io/github/stars/adamnguyenit/rails_newsfeed.svg)](https://github.com/adamnguyenit/rails_newsfeed/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/adamnguyenit/rails_newsfeed.svg)](https://github.com/adamnguyenit/rails_newsfeed/issues)
![Repo Size](https://reposs.herokuapp.com/?path=adamnguyenit/rails_newsfeed)

This is a gem for newsfeed module on rails. It uses Cassandra >= 2.x to store data and control your feeds system.

## Installation
  *Requirement*

- Cassandra >= 2.x
- Rails 4
- Ruby 2


After cassandra installed, it is recommend to increase `batch_size_fail_threshold_in_kb` in your `cassandra.yaml` and restart cassandra. Depends on your size of relation between models.

  *Gem*

  Add this line to your application's Gemfile:

  ```ruby
  gem 'rails_newsfeed'
  ```

  And then execute:

      $ bundle

  Or install it yourself as:

      $ gem install rails_newsfeed

## Usage

First, let this gem generate the cassandra config file. Run rails generation

    $ rails g rails_newsfeed:config

and change the configuration follows your system.
Then let create the schema by generator

    $ rails g rails_newsfeed:init

And create a model by

    $ rails g rails_newsfeed:model user_feed --type_of_id=bigint

Change the type_of_id option to match the type of your model

# Quick start

Save the activity first
```ruby
activity = RailsNewsfeed::Activity.new(content: 'user 1 upload photo 1')
activity.save
```

Add a feed
```ruby
user_feed = UserFeed.new(id: 1)
user_feed.insert(activity)
```

Get feeds
```ruby
user_feed = UserFeed.new(id: 1)
feeds = user_feed.feeds
next_page_token = user_feed.next_page_token
```

Delete a feed
```ruby
activity = RailsNewsfeed::Activity.find(feed_id)
activity.delete
```

Register to another feed model
```ruby
user_a_feed = UserFeed.new(id: 1)
user_b_feed = UserFeed.new(id: 2)
user_a_feed.register(user_a_feed)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Before running test you must apply these cqls into cassandra.
```ruby
CREATE KEYSPACE rails_newsfeed_test WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor': 3 };
USE rails_newsfeed_test;
CREATE TABLE activity (id uuid, content text, time timestamp, object text, PRIMARY KEY (id));
CREATE TABLE activity_index (id uuid, content text, time timestamp, object text, PRIMARY KEY ((object), id));
CREATE TABLE feed_table (table_class text, PRIMARY KEY (table_class));
CREATE TABLE relation (id uuid, from_class text, from_id text, to_class text, to_id text, PRIMARY KEY ((from_class, from_id), id));
CREATE TABLE relation_index(id uuid, from_class text, from_id text, to_class text, to_id text, PRIMARY KEY ((from_class, from_id, to_class, to_id)));
CREATE TABLE user_feed (id bigint, activity_id uuid, activity_content text, activity_object text, activity_time timestamp, PRIMARY KEY ((id), activity_id));
INSERT INTO feed_table (table_class) VALUES ('UserFeed');
```
We use rspec to test this gem.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adamnguyenit/rails_newsfeed. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
