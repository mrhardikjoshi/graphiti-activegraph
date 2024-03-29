RSpec.describe Graphiti::Deserializer do
  describe '#update_params' do
    let(:params) { {} }
    let(:env) { {} }
    let(:model) { Planet }
    let(:parent_map) { {} }
    let(:rel_name) { :star }
    let(:path_value) { 108 }
    let(:rel_params) { params[:data][:relationships] }

    subject { Graphiti::Deserializer.new(params, env, model, parent_map) }

    before do
      subject.update_params(params, rel_name, path_value)
    end

    it 'updates params with correct relationships hash' do
      expect(rel_params[rel_name]).to eq({ data: { type: 'stars', id: path_value } })
    end
  end
end
