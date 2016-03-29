RSpec.describe RailsNewsfeed::Activity do
  describe '.table_name' do
    subject { RailsNewsfeed::Activity.table_name }
    it { is_expected.to be_a(String) }
    it { is_expected.not_to be_empty }
  end

  describe '.index_table_name' do
    subject { RailsNewsfeed::Activity.index_table_name }
    it { is_expected.to be_a(String) }
    it { is_expected.not_to be_empty }
  end

  describe '.schema' do
    subject { RailsNewsfeed::Activity.schema }
    it { is_expected.to be_a(Hash) }
    it { is_expected.not_to be_empty }
    it { is_expected.to include(:id, :content, :object, :time) }
  end

  describe '.new' do
    context 'without arguments' do
      subject { RailsNewsfeed::Activity.new }
      it { is_expected.to be_a(RailsNewsfeed::Activity) }
      it { is_expected.to have_attributes(id: nil, content: nil, object: nil, time: nil, new_record: true) }
    end
    context 'with arguments' do
      let(:args) do
        { id: SecureRandom.uuid, content: 'user 1 post photo 1', object: 'photo 1',
          time: Cassandra::Types::Timestamp.new(DateTime.current).to_s, new_record: false }
      end
      subject { RailsNewsfeed::Activity.new(args) }
      it { is_expected.to be_a(RailsNewsfeed::Activity) }
      it { is_expected.to have_attributes(args) }
    end
  end

  describe '.create' do
    context 'without arguments' do
      subject { RailsNewsfeed::Activity.create }
      it { is_expected.to be_nil }
    end
    context 'without content' do
      subject { RailsNewsfeed::Activity.create(object: 'photo 1') }
      it { is_expected.to be_nil }
    end
    context 'with content' do
      subject { RailsNewsfeed::Activity.create(content: 'user 1 post photo 1') }
      it { is_expected.not_to be_nil }
      it { is_expected.to be_a(RailsNewsfeed::Activity) }
    end
  end

  describe '.create!' do
    context 'without arguments' do
      subject { RailsNewsfeed::Activity.create! }
      it { is_expected.to be_nil }
    end
    context 'without content' do
      subject { RailsNewsfeed::Activity.create!(object: 'photo 1') }
      it { is_expected.to be_nil }
    end
    context 'with content' do
      subject { RailsNewsfeed::Activity.create!(content: 'user 1 post photo 1') }
      it { is_expected.not_to be_nil }
      it { is_expected.to be_a(RailsNewsfeed::Activity) }
    end
    context 'wrong id format' do
      subject { RailsNewsfeed::Activity.create!(id: 'photo 1') }
      it { is_expected.to be_nil }
    end
  end

  describe '.all' do
    context 'without arguments' do
      subject { RailsNewsfeed::Activity.all }
      it { is_expected.to be_a(Array) }
      it 'should pass logic' do
        sub = lambda do
          RailsNewsfeed::Activity.delete
          create_list(:activity, 100)
          RailsNewsfeed::Activity.all
        end
        expect(sub.call).to be_a(Array)
        expect(sub.call).to have_exactly(100).items
        expect(sub.call).to all(be_a(RailsNewsfeed::Activity))
      end
    end
    context 'with { :object => object }' do
      subject { RailsNewsfeed::Activity.all(object: 'photo 1') }
      it { is_expected.to be_a(Array) }
      it 'should pass logic' do
        sub = lambda do
          RailsNewsfeed::Activity.delete
          create_list(:activity, 100)
          @acts = create_list(:activity_with_object_test, 200)
          RailsNewsfeed::Activity.all(object: @acts.first.object)
        end
        expect(sub.call).to be_a(Array)
        expect(sub.call).to have_exactly(@acts.length).items
        expect(sub.call).to all(be_a(RailsNewsfeed::Activity))
        expect(sub.call).to all(have_attributes(object: @acts.first.object))
      end
    end
    context 'empty' do
      subject do
        RailsNewsfeed::Activity.delete
        RailsNewsfeed::Activity.all
      end
      it { is_expected.to be_a(Array) }
    end
  end

  describe '.delete' do
    context 'without arguments' do
      subject { RailsNewsfeed::Activity.delete }
      it { is_expected.to eq(true) }
      it 'should delete all items' do
        sub = lambda do
          create_list(:activity, 100)
          RailsNewsfeed::Activity.delete
          RailsNewsfeed::Activity.all
        end

        expect(sub.call).to be_empty
        expect(sub.call).to be_a(Array)
      end
    end
    context 'with { :a => "b" }' do
      subject { RailsNewsfeed::Activity.delete(a: 'b') }
      it { is_expected.to eq(true) }
      it 'should delete all items' do
        sub = lambda do
          create_list(:activity, 100)
          RailsNewsfeed::Activity.delete(a: 'b')
          RailsNewsfeed::Activity.all
        end
        expect(sub.call).to be_empty
        expect(sub.call).to be_a(Array)
      end
    end
    context 'with { :object => object }' do
      subject { RailsNewsfeed::Activity.delete(object: 'object') }
      it { is_expected.to eq(true) }
      it 'should delete all items of object' do
        sub = lambda do
          RailsNewsfeed::Activity.delete
          acts_obj = create_list(:activity_with_object_test, 10)
          create_list(:activity_empty_object, 12)
          RailsNewsfeed::Activity.delete(object: acts_obj.first.object)
          RailsNewsfeed::Activity.all(object: acts_obj.first.object)
        end
        expect(sub.call).to be_empty
        expect(sub.call).to be_a(Array)
      end
      it 'should have other items' do
        sub = lambda do
          @total = 12
          RailsNewsfeed::Activity.delete
          acts_obj = create_list(:activity_with_object_test, 10)
          create_list(:activity_empty_object, @total)
          RailsNewsfeed::Activity.delete(object: acts_obj.first.object)
          RailsNewsfeed::Activity.all
        end
        expect(sub.call).not_to be_empty
        expect(sub.call).to be_a(Array)
        expect(sub.call).to all(be_a(RailsNewsfeed::Activity))
        expect(sub.call).to have_exactly(@total).items
      end
    end
  end

  describe '.delete!' do
    context 'without arguments' do
      subject { RailsNewsfeed::Activity.delete! }
      it { is_expected.to eq(true) }
      it 'should delete all items' do
        sub = lambda do
          RailsNewsfeed::Activity.delete!
          create_list(:activity, 100)
          RailsNewsfeed::Activity.delete!
          RailsNewsfeed::Activity.all
        end
        expect(sub.call).to be_empty
        expect(sub.call).to be_a(Array)
      end
    end
    context 'with { :a => "b" }' do
      subject { RailsNewsfeed::Activity.delete!(a: 'b') }
      it { is_expected.to eq(true) }
      it 'should delete all items' do
        sub = lambda do
          RailsNewsfeed::Activity.delete!
          create_list(:activity, 100)
          RailsNewsfeed::Activity.delete!(a: 'b')
          RailsNewsfeed::Activity.all
        end
        expect(sub.call).to be_empty
        expect(sub.call).to be_a(Array)
      end
    end
    context 'with { :object => object }' do
      subject { RailsNewsfeed::Activity.delete!(object: 'object') }
      it { is_expected.to eq(true) }
      it 'should delete all items of object' do
        sub = lambda do
          RailsNewsfeed::Activity.delete!
          acts_obj = create_list(:activity_with_object_test, 10)
          create_list(:activity_empty_object, 12)
          RailsNewsfeed::Activity.delete!(object: acts_obj.first.object)
          RailsNewsfeed::Activity.all(object: acts_obj.first.object)
        end
        expect(sub.call).to be_empty
        expect(sub.call).to be_a(Array)
      end
      it 'should have other items' do
        sub = lambda do
          @total = 12
          RailsNewsfeed::Activity.delete!
          acts_obj = create_list(:activity_with_object_test, 10)
          create_list(:activity_empty_object, @total)
          RailsNewsfeed::Activity.delete!(object: acts_obj.first.object)
          RailsNewsfeed::Activity.all
        end
        expect(sub.call).not_to be_empty
        expect(sub.call).to be_a(Array)
        expect(sub.call).to all(be_a(RailsNewsfeed::Activity))
        expect(sub.call).to have_exactly(12).items
      end
    end
  end

  describe '.find' do
    context 'without arguments' do
      sub = -> { RailsNewsfeed::Activity.find }
      it 'raise ArgumentError' do
        expect { sub.call }.to raise_error(ArgumentError)
      end
    end
    context 'wrong id format' do
      sub = -> { RailsNewsfeed::Activity.find('photo 1') }
      it 'raise Cassandra::Errors::SyntaxError' do
        expect { sub.call }.to raise_error(Cassandra::Errors::SyntaxError)
      end
    end
    context 'non-existed if' do
      subject { RailsNewsfeed::Activity.find(SecureRandom.uuid) }
      it { is_expected.to be_nil }
    end
  end

  describe '.find' do
    context 'without arguments' do
      sub = -> { RailsNewsfeed::Activity.find! }
      it 'raise ArgumentError' do
        expect { sub.call }.to raise_error(ArgumentError)
      end
    end
    context 'wrong id format' do
      subject { RailsNewsfeed::Activity.find!('photo 1') }
      it { is_expected.to be_nil }
    end
    context 'non-existed if' do
      subject { RailsNewsfeed::Activity.find!(SecureRandom.uuid) }
      it { is_expected.to be_nil }
    end
  end

  describe '.create_from_cass' do
    context 'from cass activity' do
      subject do
        @act = create(:activity)
        cass_act = RailsNewsfeed::Connection.select(RailsNewsfeed::Activity.table_name, RailsNewsfeed::Activity.schema,
                                                    '*', id: @act.id)
        RailsNewsfeed::Activity.create_from_cass(:act, cass_act.first)
      end
      it { is_expected.not_to be_nil }
      it { is_expected.to be_a(RailsNewsfeed::Activity) }
      it { is_expected.to have_attributes(@act.to_h) }
    end
  end

  describe '#id' do
    act = RailsNewsfeed::Activity.new
    context 'get' do
      it 'ok' do
        expect { act.id }.not_to raise_error
      end
    end
    context 'set' do
      it 'raises NoMethodError' do
        expect { act.id = 1 }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#content' do
    act = RailsNewsfeed::Activity.new
    context 'get' do
      it 'ok' do
        expect { act.content }.not_to raise_error
      end
    end
    context 'set' do
      it 'ok' do
        expect { act.content = 1 }.not_to raise_error
      end
    end
  end

  describe '#object' do
    act = RailsNewsfeed::Activity.new
    context 'get' do
      it 'ok' do
        expect { act.object }.not_to raise_error
      end
    end
    context 'set' do
      it 'ok' do
        expect { act.object = 1 }.not_to raise_error
      end
    end
  end

  describe '#time' do
    act = RailsNewsfeed::Activity.new
    context 'get' do
      it 'ok' do
        expect { act.time }.not_to raise_error
      end
    end
    context 'set' do
      it 'ok' do
        expect { act.time = 1 }.not_to raise_error
      end
    end
  end

  describe '#new_record' do
    act = RailsNewsfeed::Activity.new
    context 'get' do
      it 'ok' do
        expect { act.new_record }.not_to raise_error
      end
    end
    context 'set' do
      it 'raises NoMethodError' do
        expect { act.new_record = 1 }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#to_h' do
    let(:args) do
      { id: SecureRandom.uuid, content: 'user 1 post photo 1', object: 'photo 1',
        time: Cassandra::Types::Timestamp.new(DateTime.current).to_s, new_record: false }
    end
    context 'without prefix' do
      subject { RailsNewsfeed::Activity.new(args).to_h }
      it { is_expected.to be_a(Hash) }
      it { is_expected.not_to be_empty }
      it { is_expected.to include(id: args[:id], content: args[:content], object: args[:object], time: args[:time]) }
    end
    context 'with prefix' do
      let(:prefix) { 'activity_' }
      subject { RailsNewsfeed::Activity.new(args).to_h(prefix) }
      it { is_expected.to be_a(Hash) }
      it { is_expected.not_to be_empty }
      it do
        is_expected.to include("#{prefix}id".to_sym => args[:id], "#{prefix}content".to_sym => args[:content],
                               "#{prefix}object".to_sym => args[:object], "#{prefix}time".to_sym => args[:time])
      end
    end
  end

  describe '#save' do
    context 'without content' do
      subject { RailsNewsfeed::Activity.new.save }
      it { is_expected.to eq(false) }
    end
    context 'with content' do
      subject { RailsNewsfeed::Activity.new(content: 'user 1 post photo 1').save }
      it { is_expected.to eq(true) }
    end
    context 'wrong id format' do
      subject { RailsNewsfeed::Activity.new(id: 'photo 1').save }
      it { is_expected.to eq(false) }
    end
    context 'save with update' do
      subject do
        act = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1')
        act.save
        act.content = 'user 1 post photo 2'
        act.save
      end
      it { is_expected.to eq(true) }
    end
  end

  describe '#save!' do
    context 'without content' do
      subject { RailsNewsfeed::Activity.new.save! }
      it { is_expected.to eq(false) }
    end
    context 'with content' do
      subject { RailsNewsfeed::Activity.new(content: 'user 1 post photo 1').save! }
      it { is_expected.to eq(true) }
    end
    context 'wrong id format' do
      subject { RailsNewsfeed::Activity.new(id: 'photo 1').save! }
      it { is_expected.to eq(false) }
    end
    context 'save with update' do
      subject do
        act = RailsNewsfeed::Activity.new(content: 'user 1 post photo 1')
        act.save!
        act.content = 'user 1 post photo 2'
        act.save!
      end
      it { is_expected.to eq(true) }
    end
  end
end
