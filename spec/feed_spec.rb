RSpec.describe 'Feed' do
  tbl = UserFeed.table_name
  act_tbl = RailsNewsfeed::Activity.table_name
  act_index_tbl = RailsNewsfeed::Activity.index_table_name

  describe 'Get non-existed id' do
    it 'OK' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
      user_feed = UserFeed.new(id: SecureRandom.random_number(1000))
      feeds = user_feed.feeds
      next_page_token = user_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
    end
  end

  describe 'Add a new feed' do
    it 'Without object, without hide old feeds, without related' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
      user_feed = UserFeed.new(id: 1)

      activity = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1')
      activity.save

      result = user_feed.insert(activity, false, false)
      expect(result).to eq(true)
      feeds = user_feed.feeds
      next_page_token = user_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)

      feed = feeds.first
      expect(feed.id).to eq(activity.id)
      expect(feed.content).to eq(activity.content)
      expect(feed.object).to eq(activity.object)
      expect(feed.time).to eq(activity.time)

      result = feed.delete(false)
      expect(result).to eq(true)
      feeds = user_feed.feeds
      next_page_token = user_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
    end

    it 'With object, without hide old feeds, without related' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
      user_feed = UserFeed.new(id: 1)

      activity = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1', object: 'photo-1')
      activity.save

      result = user_feed.insert(activity, false, false)
      expect(result).to eq(true)
      feeds = user_feed.feeds
      next_page_token = user_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)

      feed = feeds.first
      expect(feed.id).to eq(activity.id)
      expect(feed.content).to eq(activity.content)
      expect(feed.object).to eq(activity.object)
      expect(feed.time).to eq(activity.time)

      result = feed.delete(false)
      expect(result).to eq(true)
      feeds = user_feed.feeds
      next_page_token = user_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
    end

    it 'With object, with hide old feeds, without related' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
      user_feed = UserFeed.new(id: 1)

      activity_a = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1', object: 'photo-1')
      activity_a.save

      result = user_feed.insert(activity_a, false, false)
      expect(result).to eq(true)
      feeds = user_feed.feeds
      next_page_token = user_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)

      feed = feeds.first
      expect(feed.id).to eq(activity_a.id)
      expect(feed.content).to eq(activity_a.content)
      expect(feed.object).to eq(activity_a.object)
      expect(feed.time).to eq(activity_a.time)

      activity_b = RailsNewsfeed::Activity.new(content: 'user 2 like photo 1', object: 'photo-1')
      activity_b.save

      result = user_feed.insert(activity_b, false, true)
      expect(result).to eq(true)
      feeds = user_feed.feeds
      next_page_token = user_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)

      feed = feeds.first
      expect(feed.id).to eq(activity_b.id)
      expect(feed.content).to eq(activity_b.content)
      expect(feed.object).to eq(activity_b.object)
      expect(feed.time).to eq(activity_b.time)

      result = feed.delete(true)
      expect(result).to eq(true)
      feeds = user_feed.feeds
      next_page_token = user_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)
      feed = feeds.first
      expect(feed.id).to eq(activity_a.id)
      expect(feed.content).to eq(activity_a.content)
      expect(feed.object).to eq(activity_a.object)
      expect(feed.time).to eq(activity_a.time)

      result = feed.delete(true)
      expect(result).to eq(true)
      feeds = user_feed.feeds
      next_page_token = user_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
    end

    it 'With object, with hide old feeds, with related' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
      user_a_id = 1
      user_b_id = 2
      user_a_feed = UserFeed.new(id: user_a_id)
      user_b_feed = UserFeed.new(id: user_b_id)
      user_a_feed.register(user_b_feed)

      activity_a = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1', object: 'photo-1')
      activity_a.save

      result = user_a_feed.insert(activity_a)
      expect(result).to eq(true)
      feeds = user_a_feed.feeds
      next_page_token = user_a_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)

      feed = feeds.first
      expect(feed.id).to eq(activity_a.id)
      expect(feed.content).to eq(activity_a.content)
      expect(feed.object).to eq(activity_a.object)
      expect(feed.time).to eq(activity_a.time)
      feeds = user_b_feed.feeds
      next_page_token = user_b_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)
      feed = feeds.first
      expect(feed.id).to eq(activity_a.id)
      expect(feed.content).to eq(activity_a.content)
      expect(feed.object).to eq(activity_a.object)
      expect(feed.time).to eq(activity_a.time)

      activity_b = RailsNewsfeed::Activity.new(content: 'user 2 like photo 1', object: 'photo-1')
      activity_b.save

      result = user_a_feed.insert(activity_b)
      expect(result).to eq(true)
      feeds = user_a_feed.feeds
      next_page_token = user_a_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)

      feed = feeds.first
      expect(feed.id).to eq(activity_b.id)
      expect(feed.content).to eq(activity_b.content)
      expect(feed.object).to eq(activity_b.object)
      expect(feed.time).to eq(activity_b.time)
      feeds = user_b_feed.feeds
      next_page_token = user_b_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)
      feed = feeds.first
      expect(feed.id).to eq(activity_b.id)
      expect(feed.content).to eq(activity_b.content)
      expect(feed.object).to eq(activity_b.object)
      expect(feed.time).to eq(activity_b.time)

      result = feed.delete(true)
      expect(result).to eq(true)
      feeds = user_a_feed.feeds
      next_page_token = user_a_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)
      feed = feeds.first
      expect(feed.id).to eq(activity_a.id)
      expect(feed.content).to eq(activity_a.content)
      expect(feed.object).to eq(activity_a.object)
      expect(feed.time).to eq(activity_a.time)
      feeds = user_b_feed.feeds
      next_page_token = user_b_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)
      feed = feeds.first
      expect(feed.id).to eq(activity_a.id)
      expect(feed.content).to eq(activity_a.content)
      expect(feed.object).to eq(activity_a.object)
      expect(feed.time).to eq(activity_a.time)

      result = feed.delete(false)
      expect(result).to eq(true)
      feeds = user_a_feed.feeds
      next_page_token = user_a_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
      feeds = user_b_feed.feeds
      next_page_token = user_b_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
    end

    it 'Without object, without hide old feeds, with related' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
      user_a_id = 1
      user_b_id = 2
      user_a_feed = UserFeed.new(id: user_a_id)
      user_b_feed = UserFeed.new(id: user_b_id)
      user_a_feed.register(user_b_feed)

      activity = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1')
      activity.save

      result = user_a_feed.insert(activity)
      expect(result).to eq(true)
      feeds = user_a_feed.feeds
      next_page_token = user_a_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)

      feed = feeds.first
      expect(feed.id).to eq(activity.id)
      expect(feed.content).to eq(activity.content)
      expect(feed.object).to eq(activity.object)
      expect(feed.time).to eq(activity.time)
      feeds = user_b_feed.feeds
      next_page_token = user_b_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)
      feed = feeds.first
      expect(feed.id).to eq(activity.id)
      expect(feed.content).to eq(activity.content)
      expect(feed.object).to eq(activity.object)
      expect(feed.time).to eq(activity.time)

      result = feed.delete(false)
      expect(result).to eq(true)
      feeds = user_a_feed.feeds
      next_page_token = user_a_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
      feeds = user_b_feed.feeds
      next_page_token = user_b_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
    end

    it 'With object, without hide old feeds, with related' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
      user_a_id = 1
      user_b_id = 2
      user_a_feed = UserFeed.new(id: user_a_id)
      user_b_feed = UserFeed.new(id: user_b_id)
      user_a_feed.register(user_b_feed)

      activity = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1', object: 'photo-1')
      activity.save

      result = user_a_feed.insert(activity)
      expect(result).to eq(true)
      feeds = user_a_feed.feeds
      next_page_token = user_a_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)

      feed = feeds.first
      expect(feed.id).to eq(activity.id)
      expect(feed.content).to eq(activity.content)
      expect(feed.object).to eq(activity.object)
      expect(feed.time).to eq(activity.time)
      feeds = user_b_feed.feeds
      next_page_token = user_b_feed.next_page_token
      expect(feeds).not_to be_empty
      expect(feeds.length).to eq(1)
      expect(next_page_token).to eq(nil)
      feed = feeds.first
      expect(feed.id).to eq(activity.id)
      expect(feed.content).to eq(activity.content)
      expect(feed.object).to eq(activity.object)
      expect(feed.time).to eq(activity.time)

      result = feed.delete(false)
      expect(result).to eq(true)
      feeds = user_a_feed.feeds
      next_page_token = user_a_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
      feeds = user_b_feed.feeds
      next_page_token = user_b_feed.next_page_token
      expect(feeds).to be_empty
      expect(next_page_token).to eq(nil)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{act_index_tbl}")
    end
  end
end
