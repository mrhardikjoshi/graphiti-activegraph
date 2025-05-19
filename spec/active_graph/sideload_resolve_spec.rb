RSpec.describe Graphiti::Scope do
  let(:object) { {} }
  let(:resource) { Graphiti::ActiveGraph::Resource.new }
  let(:query) { {} }
  let(:opts) { {} }

  describe '#bypass_scoping' do
    it 'does not call around_scoping when :preloaded is present in opts' do
      opts = {preloaded: {foo: 1}}

      expect(resource).not_to receive(:around_scoping)
      sideload_resolver = described_class.new(object, resource, query, opts)
    end

    it 'calls around_scoping when :preloaded is not present in opts' do
      expect(resource).to receive(:around_scoping)
      sideload_resolver = described_class.new(object, resource, query, opts)
    end
  end

  describe '#resolve' do
    let(:zero_results) { false }
    let(:params) { {} }
    let(:sideloads) { [] }
    let(:extra_fields) { {} }
    let(:query) { double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads:) }
    let(:results) { [Author.new] }
    let(:scope) { described_class.new(object, resource, query, opts) }
    before { allow(resource).to receive(:around_scoping).and_return(results) }

    it 'returns correct results' do
      expect(scope.resolve).to eq(results)
    end

    it 'assigns serializer' do
      expect(scope).to receive(:assign_serializer).with(results)
      scope.resolve
    end

    context 'with after_resolve callback' do
      let(:callback) { ->(results) {} }
      let(:opts) { { after_resolve: callback } }

      it 'calls it with results' do
        expect(callback).to receive(:call).with(results)
        scope.resolve
      end
    end

    context 'zero results' do
      let(:zero_results) { true }
      subject { scope.resolve }

      it { is_expected.to eq([]) }
    end
  end
end
