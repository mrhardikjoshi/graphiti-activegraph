describe Graphiti::ActiveGraph::Scoping::Internal::SortNormalizer do
  describe '#normalize_deep_sorts' do
    let(:scope) { Author }
    let(:includes) { {} }
    subject { described_class.new(scope).normalize_deep_sort(includes, sorts) }

    context 'when straight attribute' do
      let(:sorts) { [{ [:abc] => 'ASC' }] }
      it { is_expected.to eq({ '' => ['abc ASC'] }) }
    end

    context 'when non existing relationship' do
      let(:includes) { { posts: {} } }
      let(:sorts) { [{ [:nonexisting, :abc] => 'ASC' }] }
      it { is_expected.to be_empty }
    end

    context 'when relationship attribute' do
      let(:includes) { { posts: {} } }
      let(:sorts) { [{ [:posts_rel, :score] => 'ASC' }] }
      it { is_expected.to eq({ 'posts' => [{ rel: 'score ASC' }] }) }
    end

    context 'when multiple attributes' do
      let(:includes) { { posts: {} } }
      let(:sorts) { [{ [:posts, :name] => 'ASC' }, { [:posts, :abc] => 'ASC' }] }
      it { is_expected.to eq({ 'posts' => ['name ASC', 'abc ASC'] }) }
    end
  end

  describe '#normalize_base_sort' do
    let(:scope) { Author }
    let(:sorts) { [{ id: :asc }, { name: :asc }] }
    subject { described_class.new(scope).normalize_base_sort(sorts) }

    it { is_expected.to eq({ '' => ['id asc', 'name asc'] }) }
  end
end
