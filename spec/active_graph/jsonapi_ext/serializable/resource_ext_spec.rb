require File.expand_path("../../../support/jsonapi_resource_support", __FILE__)

RSpec.describe JSONAPI::Serializable::Resource do
  let(:include) { [:planets].to_set }
  let!(:resource) { SerializableStar.new(object: sun) }
  subject { resource.as_jsonapi(include: include, fields: fields) }

  let(:sun) { Star.new(id: 1, name: 'Sun', age: 4.6, planets: planets, satellites: satellites) }
  let(:planets) { [earth, mars] }
  let(:satellites) { [moon, phobos] }

  let(:earth) { Planet.new(id: 11, name: 'Earth', temperature: 288) }
  let(:mars) { Planet.new(id: 12, name: 'Mars', temperature: 213) }

  let(:moon) { Satellite.new(id: 111, name: 'Moon', radius: 1737, planet: earth) }
  let(:phobos) { Satellite.new(id: 121, name: 'Phobos', radius: 11, planet: mars) }

  context 'with fields' do
    let(:fields) { [:satellites, :age] }

    it 'rel mentioned in fields are present' do
      expected = {
        data: [{ type: :satellites, id: '111' },
               { type: :satellites, id: '121' }]
      }
      expect(subject[:relationships][:satellites]).to eq(expected)
    end

    it 'rel not mentioned in fields are absent' do

      expect(subject[:relationships][:planets]).to be nil
    end

    it 'only attributes mentioned in fields are present' do
      expect(subject[:attributes]).to contain_exactly(*sun.attributes_map.slice(:age))
    end
  end

  context 'without fields' do
    let(:fields) { nil }

    it 'rel mentioned in include are present' do
      expected = {
        data: [{ type: :planets, id: '11' },
               { type: :planets, id: '12' }]
      }

      expect(subject[:relationships][:planets]).to eq(expected)
    end

    it 'all attributes are present' do
      expect(subject[:attributes]).to eq(sun.attributes_map)
    end
  end
end
