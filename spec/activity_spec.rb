RSpec.describe 'Activity' do
  tbl = RailsNewsfeed::Activity.table_name
  index_tbl = RailsNewsfeed::Activity.index_table_name

  describe 'Get non-existed activity' do
    it 'OK' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
      act = RailsNewsfeed::Activity.find(SecureRandom.uuid)
      expect(act).to eq(nil)
    end
  end

  describe 'Add a new activity' do
    it 'without object' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
      activity_content = 'user 1 post photo 1'
      activity = RailsNewsfeed::Activity.new(content: activity_content)
      result = activity.save
      expect(result).to eq(true)
      act = RailsNewsfeed::Activity.find(activity.id)
      expect(act).not_to eq(nil)
      expect(act.id.to_s).to eq(activity.id)
      expect(act.content).to eq(activity.content)
      expect(act.object).to eq(activity.object)
      expect(act.time).to eq(activity.time)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
    end

    it 'with object' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
      activity = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1', object: SecureRandom.hex)
      result = activity.save
      expect(result).to eq(true)
      act = RailsNewsfeed::Activity.find(activity.id)
      expect(act).not_to eq(nil)
      expect(act.id).to eq(activity.id)
      expect(act.content).to eq(activity.content)
      expect(act.object).to eq(activity.object)
      expect(act.time).to eq(activity.time)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
    end
  end

  describe 'Delete an activity' do
    it 'without object' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
      activity = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1')
      activity.save
      act = RailsNewsfeed::Activity.find(activity.id)
      expect(act).not_to eq(nil)
      expect(act.id.to_s).to eq(activity.id)
      expect(act.content).to eq(activity.content)
      expect(act.object).to eq(activity.object)
      expect(act.time).to eq(activity.time)
      result = activity.delete
      expect(result).to eq(true)
      act = RailsNewsfeed::Activity.find(activity.id)
      expect(act).to eq(nil)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
    end

    it 'with object' do
      # truncates first
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
      activity = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1', object: SecureRandom.hex)
      activity.save
      act = RailsNewsfeed::Activity.find(activity.id)
      expect(act).not_to eq(nil)
      expect(act.id).to eq(activity.id)
      expect(act.content).to eq(activity.content)
      expect(act.object).to eq(activity.object)
      expect(act.time).to eq(activity.time)
      result = activity.delete
      expect(result).to eq(true)
      act = RailsNewsfeed::Activity.find(activity.id)
      expect(act).to eq(nil)
      # truncates when finish
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{tbl}")
      RailsNewsfeed::Connection.exec_cql("TRUNCATE #{index_tbl}")
    end
  end
end
