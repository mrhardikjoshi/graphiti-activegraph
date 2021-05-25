RSpec.describe Graphiti::ActiveGraph::Deserializer do
  describe '#relationships' do
    let(:skill_rel_map) { Graphiti::Deserializer.new(payload).relationships[:skill] }
    let(:skill_id) { '2' }

    let(:payload) do
      {
        data: {
          type: 'employees',
          attributes: { first_name: 'Hardik', last_name: 'Joshi' },
          relationships: { skill: { data: { type: 'skills', id: skill_id } } }
        },
        included: [{ id: skill_id, type: 'skills', attributes: { name: 'skill name updated' } }]
      }
    end

    it 'ingores attributes update of relationships provided in "included" block' do
      expect(skill_rel_map[:attributes]).to eq({ id: skill_id })
      expect(skill_rel_map[:meta][:jsonapi_type]).to eq('skills')
    end
  end
end
