describe Graphiti::ActiveGraph::Serializer do
  describe 'Graphiti::Serializer' do
    subject { Graphiti::Serializer }

    it { is_expected.to include(Graphiti::ActiveGraph::Serializer) }
  end

  describe '#jsonapi_resource_class' do
    let(:serializer_class) do
      Class.new do
        def polymorphic?; end
        def jsonapi_type; end
      end
    end
    let(:polymorphic) { false }
    let(:resource_obj) { AuthorResource.new }
    let(:jsonapi_type) { resource_obj.type }
    let(:serializer) { serializer_class.new }

    before do
      serializer.class.include Graphiti::ActiveGraph::Serializer
      allow(serializer).to receive(:polymorphic?).and_return(polymorphic)
      allow(serializer).to receive(:jsonapi_type).and_return(jsonapi_type)
      serializer.instance_variable_set(:@resource, resource_obj)
    end

    it 'returns resource class' do
      expect(serializer.jsonapi_resource_class).to eq(AuthorResource)
    end

    context 'with polymorphic resource' do
      let(:polymorphic) { true }

      it 'returns correct resource class' do
        expect(serializer.jsonapi_resource_class).to eq(AuthorResource)
      end
    end
  end
end
