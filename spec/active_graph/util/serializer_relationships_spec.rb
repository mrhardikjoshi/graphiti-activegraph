RSpec.describe Graphiti::ActiveGraph::Util::SerializerRelationships do
  subject(:relationships) do
    Graphiti::Util::SerializerRelationships.new(resource_class, children: sideload)
  end

  let(:resource_class) { double(:resource_class, serializer: serializer) }
  let(:serializer) { double(:serializer, relationship_blocks: {}) }
  let(:sideload) { double(:sideload, name: :children, readable?: readable) }

  before do
    allow(sideload).to receive(:instance_variable_get).with(:@readable).and_return(readable_flag)
  end

  describe "#apply" do
    context "when the relationship is statically unreadable" do
      let(:readable) { false }
      let(:readable_flag) { false }

      it "does not register the relationship with the serializer" do
        expect(Graphiti::Util::SerializerRelationship).not_to receive(:new)

        relationships.apply
      end
    end

    context "when the relationship has a dynamic readability guard" do
      let(:readable) { !Graphiti::Sideload.method_defined?(:guarded?) }
      let(:readable_flag) { -> { false } }
      let(:serializer_relationship) { double(:serializer_relationship) }

      it "registers the relationship so Graphiti can evaluate the guard at runtime" do
        expect(Graphiti::Util::SerializerRelationship)
          .to receive(:new).with(resource_class, serializer, sideload)
          .and_return(serializer_relationship)
        expect(serializer_relationship).to receive(:apply)

        relationships.apply
      end
    end
  end
end
