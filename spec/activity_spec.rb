RSpec.describe RailsNewsfeed::Activity do
  describe 'initials new instance with empty arguments' do
    get_act = RailsNewsfeed::Activity.new
    subject { get_act }
    it { is_expected.to have_attributes(id: nil) }
    it { is_expected.to have_attributes(content: nil) }
    it { is_expected.to have_attributes(object: nil) }
    it { is_expected.to have_attributes(time: nil) }
    it { is_expected.to have_attributes(new_record: true) }
  end

  describe 'initials new instance with arguments' do
    args = { id: SecureRandom.uuid, content: 'user 1 post photo 1', object: 'photo 1',
             time: Cassandra::Types::Timestamp.new(DateTime.current).to_s, new_record: false }
    get_act = RailsNewsfeed::Activity.new(args)
    subject { get_act }
    it { is_expected.to have_attributes(id: args[:id]) }
    it { is_expected.to have_attributes(content: args[:content]) }
    it { is_expected.to have_attributes(object: args[:object]) }
    it { is_expected.to have_attributes(time: args[:time]) }
    it { is_expected.to have_attributes(new_record: false) }
  end

  describe 'converts to hash without prefix' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    args = { id: SecureRandom.uuid, content: 'user 1 post photo 1', object: 'photo 1',
             time: Cassandra::Types::Timestamp.new(DateTime.current).to_s, new_record: false }
    hash = RailsNewsfeed::Activity.new(args).to_h
    subject { hash }
    it { is_expected.to be_a(Hash) }
    it { is_expected.not_to be_empty }
    it { is_expected.to include(id: args[:id]) }
    it { is_expected.to include(content: args[:content]) }
    it { is_expected.to include(object: args[:object]) }
    it { is_expected.to include(time: args[:time]) }
  end

  describe 'converts to hash with prefix' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    args = { id: SecureRandom.uuid, content: 'user 1 post photo 1', object: 'photo 1',
             time: Cassandra::Types::Timestamp.new(DateTime.current).to_s, new_record: false }
    prefix = 'activity_'
    hash = RailsNewsfeed::Activity.new(args).to_h(prefix)
    subject { hash }
    it { is_expected.to be_a(Hash) }
    it { is_expected.not_to be_empty }
    it { is_expected.to include("#{prefix}id".to_sym => args[:id]) }
    it { is_expected.to include("#{prefix}content".to_sym => args[:content]) }
    it { is_expected.to include("#{prefix}object".to_sym => args[:object]) }
    it { is_expected.to include("#{prefix}time".to_sym => args[:time]) }
  end

  describe 'gets table name' do
    subject { RailsNewsfeed::Activity.table_name }
    it { is_expected.to be_a(String) }
    it { is_expected.not_to be_empty }
  end

  describe 'gets index table name' do
    subject { RailsNewsfeed::Activity.index_table_name }
    it { is_expected.to be_a(String) }
    it { is_expected.not_to be_empty }
  end

  describe 'gets schema' do
    subject { RailsNewsfeed::Activity.schema }
    it { is_expected.to be_a(Hash) }
    it { is_expected.not_to be_empty }
    it { is_expected.to include(:id) }
    it { is_expected.to include(:content) }
    it { is_expected.to include(:object) }
    it { is_expected.to include(:time) }
  end

  describe 'inserts a new activity without content' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    act = RailsNewsfeed::Activity.new
    saved = act.save
    subject { saved }
    it { is_expected.to eq(false) }
  end

  describe 'inserts a new activity without content (self)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    act = RailsNewsfeed::Activity.create
    subject { act }
    it { is_expected.to eq(nil) }
  end

  describe 'inserts a new activity with content' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    act = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1')
    saved = act.save
    subject { saved }
    it { is_expected.to eq(true) }
  end

  describe 'inserts a new activity with content (self)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    act = RailsNewsfeed::Activity.create(content: 'user 1 post photo 1')
    subject { act }
    it { is_expected.not_to eq(nil) }
    it { is_expected.to be_a(RailsNewsfeed::Activity) }
  end

  describe 'parses from cassandra result (act)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    args = { content: 'user 1 post photo 1', object: 'photo 1' }
    act = RailsNewsfeed::Activity.new(args)
    act.save
    res = RailsNewsfeed::Connection.select(RailsNewsfeed::Activity.table_name, RailsNewsfeed::Activity.schema,
                                           '*', id: act.id).first
    get_act = RailsNewsfeed::Activity.create_from_cass(:act, res)
    subject { get_act }
    it { is_expected.not_to eq(nil) }
    it { is_expected.to be_a(RailsNewsfeed::Activity) }
    it { is_expected.to have_attributes(id: act.id) }
    it { is_expected.to have_attributes(content: act.content) }
    it { is_expected.to have_attributes(object: act.object) }
    it { is_expected.to have_attributes(time: act.time) }
    it { is_expected.to have_attributes(new_record: false) }
  end

  describe 'finds non-existed activity' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    get_act = RailsNewsfeed::Activity.find(SecureRandom.uuid)
    subject { get_act }
    it { is_expected.to eq(nil) }
  end

  describe 'finds existed activity' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    args = { content: 'user 1 post photo 1', object: 'photo 1' }
    act = RailsNewsfeed::Activity.new(args)
    act.save
    get_act = RailsNewsfeed::Activity.find(act.id)
    subject { get_act }
    it { is_expected.not_to eq(nil) }
    it { is_expected.to be_a(RailsNewsfeed::Activity) }
    it { is_expected.to have_attributes(id: act.id) }
    it { is_expected.to have_attributes(content: act.content) }
    it { is_expected.to have_attributes(object: act.object) }
    it { is_expected.to have_attributes(time: act.time) }
    it { is_expected.to have_attributes(new_record: false) }
  end

  describe 'gets all activities' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    normal = Random.rand(1_000) + 1
    acts = []
    (1..normal).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}")) }
    get_acts = RailsNewsfeed::Activity.all
    subject { get_acts }
    it { is_expected.to be_a(Array) }
    it { is_expected.to all(be_a(RailsNewsfeed::Activity)) }
    it { is_expected.to have_exactly(normal).items }
  end

  describe 'gets all activities of object' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    normal = Random.rand(1_000) + 1
    total_object = Random.rand(1_000) + 1
    object = 'test'
    acts = []
    (1..normal).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}")) }
    (1..total_object).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}", object: object)) }
    get_acts = RailsNewsfeed::Activity.all(object: object)
    subject { get_acts }
    it { is_expected.to be_a(Array) }
    it { is_expected.to all(be_a(RailsNewsfeed::Activity)) }
    it { is_expected.to have_exactly(total_object).items }
  end

  describe 'updates activity' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    act = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1')
    act.save
    act.content = 'user 2 post photo 1'
    saved = act.save
    subject { saved }
    it { is_expected.to eq(true) }
  end

  describe 'updates activity (logic)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    act = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1')
    act.save
    act.content = 'user 2 post photo 1'
    act.save
    get_act = RailsNewsfeed::Activity.find(act.id)
    subject { get_act }
    it { is_expected.not_to eq(nil) }
    it { is_expected.to be_a(RailsNewsfeed::Activity) }
    it { is_expected.to have_attributes(id: act.id) }
    it { is_expected.to have_attributes(content: act.content) }
    it { is_expected.to have_attributes(object: act.object) }
    it { is_expected.to have_attributes(time: act.time) }
    it { is_expected.to have_attributes(new_record: false) }
  end

  describe 'deletes activity' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    args = { content: 'user 1 post photo 1', object: 'photo 1' }
    act = RailsNewsfeed::Activity.new(args)
    act.save
    deleted = act.delete
    subject { deleted }
    it { is_expected.to eq(true) }
  end

  describe 'deletes activity (logic)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    args = { content: 'user 1 post photo 1', object: 'photo 1' }
    act = RailsNewsfeed::Activity.new(args)
    act.save
    act.delete
    get_acts = RailsNewsfeed::Activity.all
    subject { get_acts }
    it { is_expected.to be_a(Array) }
    it { is_expected.to be_empty }
  end

  describe 'deletes activity (self)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    args = { content: 'user 1 post photo 1', object: 'photo 1' }
    act = RailsNewsfeed::Activity.new(args)
    act.save
    deleted = RailsNewsfeed::Activity.delete(id: act.id)
    subject { deleted }
    it { is_expected.to eq(true) }
  end

  describe 'deletes activity (self) (logic)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    args = { content: 'user 1 post photo 1', object: 'photo 1' }
    act = RailsNewsfeed::Activity.new(args)
    act.save
    RailsNewsfeed::Activity.delete(id: act.id)
    get_acts = RailsNewsfeed::Activity.all
    subject { get_acts }
    it { is_expected.to be_a(Array) }
    it { is_expected.to be_empty }
  end

  describe 'deletes all activities' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    normal = Random.rand(1_000) + 1
    acts = []
    (1..normal).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}")) }
    deleted = RailsNewsfeed::Activity.delete
    subject { deleted }
    it { is_expected.to eq(true) }
  end

  describe 'deletes all activities (logic)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    normal = Random.rand(1_000) + 1
    acts = []
    (1..normal).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}")) }
    RailsNewsfeed::Activity.delete
    get_acts = RailsNewsfeed::Activity.all
    subject { get_acts }
    it { is_expected.to be_a(Array) }
    it { is_expected.to be_empty }
  end

  describe 'deletes all activities of object' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    normal = Random.rand(1_000) + 1
    total_object = Random.rand(1_000) + 1
    object = 'test'
    acts = []
    (1..normal).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}")) }
    (1..total_object).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}", object: object)) }
    deleted = RailsNewsfeed::Activity.delete(object: object)
    subject { deleted }
    it { is_expected.to eq(true) }
  end

  describe 'deletes all activities of object (logic) (object)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    normal = Random.rand(1_000) + 1
    total_object = Random.rand(1_000) + 1
    object = 'test'
    acts = []
    (1..normal).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}")) }
    (1..total_object).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}", object: object)) }
    RailsNewsfeed::Activity.delete(object: object)
    get_acts = RailsNewsfeed::Activity.all(object: object)
    subject { get_acts }
    it { is_expected.to be_a(Array) }
    it { is_expected.to be_empty }
  end

  describe 'deletes all activities of object (logic) (all)' do
    # truncates first
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.table_name}")
    RailsNewsfeed::Connection.exec_cql("TRUNCATE #{RailsNewsfeed::Activity.index_table_name}")
    normal = Random.rand(1_000) + 1
    total_object = Random.rand(1_000) + 1
    object = 'test'
    acts = []
    (1..normal).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}")) }
    (1..total_object).each { |i| acts.push(RailsNewsfeed::Activity.create(content: "activity #{i}", object: object)) }
    RailsNewsfeed::Activity.delete(object: object)
    get_acts = RailsNewsfeed::Activity.all
    subject { get_acts }
    it { is_expected.to be_a(Array) }
    it { is_expected.to have_exactly(normal).items }
  end
end
