RSpec.describe Graphiti::ActiveGraph::Deserializer do
  let(:deserializer) { described_class.new(params, env, model, parent_map) }
  let(:params) { { data: {'type': 'planet'} } }
  let(:env) { {} }
  let(:model) { Planet }
  let(:parent_map) { {} }

  describe '#update_params' do
    let(:parent_map) { {} }
    let(:rel_name) { :star }
    let(:path_value) { 108 }
    let(:rel_params) { params[:data][:relationships] }

    before { deserializer.send(:update_params, params, rel_name, path_value) }

    it 'updates params with correct relationships hash' do
      expect(rel_params[rel_name]).to eq({ data: { type: 'stars', id: path_value } })
    end
  end

  describe '#parsable_content?' do
    subject { deserializer.send(:parsable_content?) }

    it { is_expected.to be true }
  end

  describe '#meta_params' do
    subject { deserializer.meta_params }
    let(:meta_params) { {'custom': 1} }

    context 'with meta params' do
      let(:params) { { data: { meta: meta_params } } }

      it { is_expected.to eq meta_params }
    end

    context 'without meta params' do
      it { is_expected.to eq({}) }
    end
  end

  describe '#relationship_id' do
    let(:rel_data) { { data: { id: 1, type: 'satellites' } } }
    let(:params) { { data: { relationships:  { satellites: rel_data } } }.with_indifferent_access }
    subject { deserializer.relationship_id(:satellites) }

    it { is_expected.to be 1 }

    context 'with no relationship in payload' do
      let(:params) { { data: {'type': 'planet'} } }
      it { is_expected.to be nil }
    end
  end

  describe '#relationship_ids' do
    let(:rel_data) { { data: [{ id: 1, type: 'satellites' }] } }
    let(:params) { { data: { relationships:  { satellites: rel_data } } }.with_indifferent_access }
    subject { deserializer.relationship_ids(:satellites) }

    it { is_expected.to contain_exactly(1) }

    context 'with multiple relationships in payload' do
      let(:rel_data) { { data: [{ id: 1, type: 'satellites' }, { id: 29, type: 'satellites' }] } }
      it { is_expected.to contain_exactly(1, 29) }
    end

    context 'with no relationship in payload' do
      let(:params) { { data: {'type': 'planet'} } }
      it { is_expected.to be_empty }
    end
  end

  describe '#relationship?' do
    subject { deserializer.relationship?(rel_name) }

    let(:params) { { data: { 'relationships':  { 'satellites': rel_data } } } }
    let(:rel_name) { 'satellites' }
    let(:rel_data) { { data: { id: 1, type: 'satellites' } } }

    it { is_expected.to be true }

    context 'without relationship' do
      let(:rel_name) { 'stars' }

      it { is_expected.to be false }
    end

    context 'with empty relationships param' do
      let(:params) { { data: {'type': 'planet'} } }
      let(:rel_name) { 'satellites' }

      it { is_expected.to be false }
    end
  end
end
