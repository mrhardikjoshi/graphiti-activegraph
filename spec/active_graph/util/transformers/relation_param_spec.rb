describe Graphiti::ActiveGraph::Util::Transformers::RelationParam do
  let(:rel) { 'knows' }
  let(:limit) { '3*knows' }
  let(:variable_length) { 'knows*' }
  let(:fix_length) { 'knows*2' }
  let(:range_length) { 'knows*2..4' }
  let(:limit_n_variable_length) { '3*knows*2' }
  let(:limit_n_fix_length) { '4*knows*2' }
  let(:limit_n_range_length) { '60*knows*2..4' }

  describe '#split_rel_length' do
    context 'when retaining rel limit' do
      it 'returns correct results' do
        {
          rel                     => [:knows, nil],
          limit                   => [:'3*knows', nil],
          variable_length         => [:knows, ''],
          fix_length              => [:knows, '2'],
          range_length            => [:knows, '2..4'],
          limit_n_variable_length => [:'3*knows', '2'],
          limit_n_fix_length      => [:'4*knows', '2'],
          limit_n_range_length    => [:'60*knows', '2..4']
        }.each do |key, value|
          expect(described_class.new(key).split_rel_length(true)).to eq(value)
        end
      end
    end

    context 'without retaining rel limit' do
      it 'returns correct results' do
        {
          rel                     => [:knows, nil],
          limit                   => [:knows, nil],
          variable_length         => [:knows, ''],
          fix_length              => [:knows, '2'],
          range_length            => [:knows, '2..4'],
          limit_n_variable_length => [:knows, '2'],
          limit_n_fix_length      => [:knows, '2'],
          limit_n_range_length    => [:knows, '2..4']
        }.each do |key, value|
          expect(described_class.new(key).split_rel_length(false)).to eq(value)
        end
      end
    end
  end

  describe '#rel_name_sym' do
    it 'returns only rel name' do
      [rel, limit, variable_length, fix_length, range_length, limit_n_variable_length,
       limit_n_fix_length, limit_n_range_length].each do |str|
        expect(described_class.new(str).rel_name_sym).to eq(:knows)
      end
    end
  end

  describe '#rel_name_n_length' do
    it 'returns relation name with length part' do
      {
        rel                     => 'knows',
        limit                   => 'knows',
        variable_length         => 'knows*',
        fix_length              => 'knows*2',
        range_length            => 'knows*2..4',
        limit_n_variable_length => 'knows*2',
        limit_n_fix_length      => 'knows*2',
        limit_n_range_length    => 'knows*2..4'
      }.each do |key, value|
        expect(described_class.new(key).rel_name_n_length).to eq(value)
      end
    end
  end

  describe '#rel_limit_number' do
    it 'returns correct limit digit' do
      {
        rel                     => nil,
        limit                   => '3',
        variable_length         => nil,
        fix_length              => nil,
        range_length            => nil,
        limit_n_variable_length => '3',
        limit_n_fix_length      => '4',
        limit_n_range_length    => '60'
      }.each do |key, value|
        expect(described_class.new(key).rel_limit_number).to eq(value)
      end
    end
  end
end
