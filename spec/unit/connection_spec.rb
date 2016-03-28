RSpec.describe RailsNewsfeed::Connection do
  describe '.config' do
    subject { RailsNewsfeed::Connection.config }
    it { is_expected.not_to be_empty }
    it { is_expected.to be_a(Hash) }
  end

  describe '.connection' do
    subject { RailsNewsfeed::Connection.connection }
    it { is_expected.not_to be_nil }
    it { is_expected.to be_a(Cassandra::Session) }
  end

  describe '.exec_cql' do
    context 'with wrong CQL' do
      sub = -> { RailsNewsfeed::Connection.exec_cql('This is a wrong CQL') }
      it 'raise Cassandra::Errors::SyntaxError' do
        expect { sub.call }.to raise_error(Cassandra::Errors::SyntaxError)
      end
    end
    context 'with right CQL' do
      subject { RailsNewsfeed::Connection.exec_cql('CREATE TABLE IF NOT EXISTS test (id uuid PRIMARY KEY)') }
      it { is_expected.not_to be_nil }
      it { is_expected.to be_a(Cassandra::Result) }
    end
  end

  describe '.batch_cqls' do
  end

  describe '.insert' do
  end

  describe '.update' do
  end

  describe '.delete' do
  end

  describe '.select' do
  end
end
