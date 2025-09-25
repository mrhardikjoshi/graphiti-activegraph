RSpec.describe Graphiti::ActiveGraph::RequestValidators::Validator do
  let(:test_class) { Class.new(Graphiti::RequestValidator) }
  let(:validator_obj) { test_class.new(double(:resource), params, :get) }
  let(:params) { {} }

  describe "#deserialized_payload" do
    it "uses Graphiti::ActiveGraph deserialzer" do
      expect(validator_obj.deserialized_payload).to be_a(Graphiti::ActiveGraph::Deserializer)
    end

    context "when params" do
      let(:params) { {type: "planets"} }

      it "uses Graphiti::ActiveGraph deserialzer" do
        expect(validator_obj.deserialized_payload.params).to eq(params)
      end
    end
  end
end
