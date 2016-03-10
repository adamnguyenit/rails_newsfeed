RSpec.describe 'Relation' do
  tbl = RailsNewsfeed::Relation.table_name
  index_tbl = RailsNewsfeed::Relation.index_table_name
  describe 'Get non-existed id' do
  end

  describe 'Add/Delete relation' do
    it 'one way' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
      user_a_id = 1
      user_b_id = 2
      user_a_feed = UserFeed.new(id: user_a_id)
      user_b_feed = UserFeed.new(id: user_b_id)
      result = user_a_feed.register(user_b_feed)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(true)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(false)
      result = user_a_feed.deregister(user_b_feed)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(false)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(false)
    end

    it 'both way' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
      user_a_id = 1
      user_b_id = 2
      user_a_feed = UserFeed.new(id: user_a_id)
      user_b_feed = UserFeed.new(id: user_b_id)
      result = user_a_feed.register(user_b_feed, side: :both)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(true)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(true)
      result = user_a_feed.deregister(user_b_feed, side: :both)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(false)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(false)

      result = user_b_feed.register(user_a_feed, side: :both)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(true)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(true)
      result = user_b_feed.deregister(user_a_feed, side: :both)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(false)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(false)

      result = user_a_feed.register(user_b_feed, side: :both)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(true)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(true)
      result = user_a_feed.deregister(user_b_feed)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(false)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(true)

      result = user_b_feed.register(user_a_feed, side: :both)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(true)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(true)
      result = user_b_feed.deregister(user_a_feed)
      expect(result).to eq(true)
      result = user_a_feed.register?(user_b_feed)
      expect(result).to eq(true)
      result = user_b_feed.register?(user_a_feed)
      expect(result).to eq(false)
    end
  end
end
