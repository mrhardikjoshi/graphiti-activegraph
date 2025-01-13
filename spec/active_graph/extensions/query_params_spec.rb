RSpec.describe Graphiti::ActiveGraph::Extensions::QueryParams do
  let(:params) { {} }
  let(:resource_class) { double(:resource_class) }
  let(:grouping_extra_params) { {} }

  subject { described_class.new(params, resource_class, grouping_extra_params:) }

  describe '#extra_field?' do
    let(:extra_fields) { {} }
    let(:params) { {extra_fields:} }

    context 'with extra_field in params' do
      let(:extra_fields) { { planets: ['perihelion', 'aphelion'] } }

      it 'returns true' do
        expect(subject.extra_field?(:planets, :perihelion)).to be true
      end
    end

    context 'without extra_field in params' do
      let(:extra_fields) { { planets: ['aphelion'] } }

      it 'returns false' do
        expect(subject.extra_field?(:planets, :perihelion)).to be false
      end
    end
  end
end
