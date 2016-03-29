# Install Cassandra

## Install OpenJDK 8

With Ubuntu 15.04

    $ sudo apt-get install openjdk-8-jre


With other versions of Ubuntu

    $ sudo add-apt-repository ppa:openjdk-r/ppa
    $ sudo apt-get update
    $ sudo apt-get install openjdk-8-jre

## Install Cassandra

Edit `sources.list`

    $ sudo nano /etc/apt/sources.list

And add 2 lines bellow

    deb http://www.apache.org/dist/cassandra/debian 30x main
    deb-src http://www.apache.org/dist/cassandra/debian 30x main

Add some publish keys

    $ gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
    $ gpg --export --armor F758CE318D77295D | sudo apt-key add -
    $ gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
    $ gpg --export --armor 0353B12C | sudo apt-key add -

Then run

    $ sudo apt-get update
    $ sudo apt-get install cassandra

### Optional

Increase `batch_size_fail_threshold_in_kb` in `/etc/cassandra/cassandra.yaml`. We recommend `5000`.


# Create app

## Require

- ruby ~> 2.0
- rails ~> 4.2
- jbuilder ~> 2.0
- Cassandra ~> 2.2

## Create newsfeed app

Create new rails app `newsfeed`

    $ rails new newsfeed

Add gem `gem 'rails_newsfeed'` to `Gemfile`. Then

    $ bundle install

It will install some dependencies and gem rails_newsfeed.

## Configuration

    $ rails g rails_newsfeed:config
    $ rails g rails_newsfeed:init

The first command will generate `config/cassandra.yml` for you. Just leave it for default.

The second command will read the configuration and create your cassandra schema.

## Models

Let's configure cassandra for our app. Run these command

    $ rails g rails_newsfeed:model user_profile_feed

This command will generate you feed model class named `UserProfileFeed` as `app/models/user_profile_feed.rb`. And also
create the table `user_profile_feed` on cassandra.

We already have the model.

## Controllers

We want to add some APIs to controll newsfeed:

    GET /users/:id/activities # Gets newsfeed of user
    POST /users/:id/activities # Creates an activity for user
    DELETE /users/:id/activities/:activity_id # Hides an activity from user's newsfeed
    DELETE /activities/:id # Removes an activity
    POST /users/:id/related # Registers to another newsfeed
    DELETE /users/:id/related/:related_id # Deregisters from the other

So, create controllers first

    $ rails g controller user
    $ rails g controller activity

Also change the argument of `protect_from_forgery` to `with: :null_session` from `app/controller/application_controller`.

    protect_from_forgery with: :null_session

Let's open `config/routes.rb` and add some lines:

    get 'users/:id/activities' => 'user#activities'
    post 'users/:id/activities' => 'user#new_activity'
    delete 'users/:id/activities/:activity_id' => 'user#hide_activity'
    delete 'activities/:id' => 'activity#remove_activity'
    post 'users/:id/related' => 'user#new_related'
    delete 'users/:id/related/:related_id' => 'user#remove_related'

Put this content to `app/controller/user_controller.rb`:

```ruby
class UserController < ApplicationController
  def activities
    params.permit(:id, :limit, :next_page_token)
    user_profile_feed_model = UserProfileFeed.new(id: params[:id], next_page_token: params[:next_page_token])
    @user_profile_feeds = user_profile_feed_model.feeds(params[:limit] || 10)
    @next_page_token = user_profile_feed_model.next_page_token
    render template: 'users/index'
  end

  def new_activity
    params.permit(:id, :content, :object)
    @activity = RailsNewsfeed::Activity.create(content: params[:content], object: params[:object])
    user_profile_feed_model = UserProfileFeed.new(id: params[:id])
    user_profile_feed_model.insert(@activity)
    render template: 'users/new_activity'
  end

  def hide_activity
    params.permit(:id, :activity_id)
    UserProfileFeed.delete(params[:id], params[:activity_id], false)
    render nothing: true
  end

  def new_related
    params.permit(:id, :related_id)
    user_a_profile_feed_model = UserProfileFeed.new(id: params[:id])
    user_b_profile_feed_model = UserProfileFeed.new(id: params[:related_id])
    user_a_profile_feed_model.register(user_b_profile_feed_model)
    render nothing: true
  end

  def remove_related
    params.permit(:id, :related_id)
    user_a_profile_feed_model = UserProfileFeed.new(id: params[:id])
    user_b_profile_feed_model = UserProfileFeed.new(id: params[:related_id])
    user_a_profile_feed_model.deregister(user_b_profile_feed_model)
    render nothing: true
  end
end
```

And `app/controller/activity_controller.rb`:

```ruby
class ActivityController < ApplicationController
  def remove_activity
    params.permit(:id)
    RailsNewsfeed::Activity.delete(id: params[:id])
    render nothing: true
  end
end
```

Ok. The controllers are fine. Let's create views.

## Views

Create a new file `app/views/partials/_activity.json.jbuilder` with content:

```ruby
json.set! :id, activity.id
json.set! :content, activity.content
json.set! :object, activity.object
json.set! :time, activity.time
```

Create a new file `app/views/users/index.json.jbuilder` with content:

```ruby
json.activities @user_profile_feeds, partial: 'partials/activity', as: :activity
json.next_page_token @next_page_token
```

Create a new file `app/views/users/new_activity.json.jbuilder` with content:

```ruby
json.activity @activity, partial: 'partials/activity', as: :activity
```

You are all set!

## Run

Run server

    $ rails s -b 0.0.0.0

To add new activity for user, call API `POST /users/:id/activities` with data:

    content: <activity_data_as_string>
    object: <object_of_activity>

To get newsfeed of user, call API `GET /users/:id/activities?limit=10` with `limit` is size of feed per page.

To register to another newsfeed, call API `POST /users/:id/related` with data"

    related_id: <newsfeed_user_id>

To deregister, call API `DELETE /users/:id/related/:related_id`

To delete an activity, call API `DELETE /activities/:activity_id'`

To hide an activity from user's newsfeed, call API `DELETE /users/:id/activities/:activity_id`
