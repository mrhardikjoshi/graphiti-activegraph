RSpec.describe Graphiti::Scope do
  describe '#bypass_scoping' do
    let(:object) { {} }
    let(:resource) { Graphiti::Resource.new }
    let(:query) { {} }

    it 'does not call around_scoping when :preloaded is present in opts' do
      opts = {preloaded: {foo: 1}}

      expect(resource).not_to receive(:around_scoping)
      sideload_resolver = described_class.new(object, resource, query, opts)
    end

    it 'calls around_scoping when :preloaded is not present in opts' do
      opts = {}

      expect(resource).to receive(:around_scoping)
      sideload_resolver = described_class.new(object, resource, query, opts)
    end
  end

  describe
end
