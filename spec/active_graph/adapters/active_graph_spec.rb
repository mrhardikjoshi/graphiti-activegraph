RSpec.describe Graphiti::ActiveGraph::Adapters::ActiveGraph do
  let(:resource) { double(:resource) }
  let(:adapter) { described_class.new(resource) }
  let(:model_instance) { double(:model_instance) }
  let(:attributes) { {attr_one: "some_value", attr_two: false, rel: double(:rel)} }

  describe "#assign_attributes" do
    # https://github.com/neo4jrb/activegraph/issues/1445
    # saves attributes till above issue is fixed
    # change the test to check for assignment after fix
    it "updates correctly" do
      expect(model_instance).to receive(:update).with(attributes)
      adapter.assign_attributes(model_instance, attributes)
    end
  end

  describe "#save" do
    context "when no change" do
      it "does not hit save" do
        expect(model_instance).to receive(:changed?).and_return(false)
        expect(model_instance).not_to receive(:save)
        adapter.save(model_instance)
      end
    end

    context "with change" do
      it "saves" do
        expect(model_instance).to receive(:changed?).and_return(true)
        expect(model_instance).to receive(:save)
        adapter.save(model_instance)
      end
    end
  end
end
