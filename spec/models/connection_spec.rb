RSpec.describe RailsNewsfeed::Connection do
  describe '.connection' do
    connection = RailsNewsfeed::Connection.connection
    context 'when ok' do
      subject { connection }
      it { is_expected.not_to eq(nil) }
      it { is_expected.to be_a(Cassandra::Session) }
    end
  end
end
