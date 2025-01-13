RSpec.describe Graphiti::ActiveGraph::Extensions::Grouping::Params do
  let(:params) { {} }
  let(:resource_class) { double(:resource_class) }
  let(:params) { {group_by:} }
  let(:group_by) {}
  let(:obj) { described_class.new(params, resource_class) }

  describe '#empty?' do
    subject { obj.empty? }

    describe 'criteria' do
      context 'when present' do
        let(:group_by) { 'axial_tilt' }
        it { is_expected.to be false }

        context 'with multiple values' do
          let(:group_by) { 'axial_tilt,north_pole_declination' }
          it { is_expected.to be false }
        end
      end

      context 'when absent' do
        let(:params) { {} }
        it { is_expected.to be true }
      end

      context 'when nil' do
        let(:group_by) { nil }
        it { is_expected.to be true }
      end

      context 'when empty string' do
        let(:group_by) { '' }
        it { is_expected.to be true }
      end
    end
  end

  describe '#single_grouping_criteria?' do
    subject { obj.single_grouping_criteria? }

    context 'with single value' do
      let(:group_by) { 'axial_tilt' }
      it { is_expected.to be true }
    end

    context 'with multiple values' do
      let(:group_by) { 'axial_tilt,north_pole_declination' }
      it { is_expected.to be false }
    end
  end

  describe '#grouping_criteria_on_attribute?' do
    subject { obj.grouping_criteria_on_attribute? }

    let(:resource_class) { PlanetResource }

    context 'without criteria' do
      let(:group_by) { nil }
      it { is_expected.to be false }
    end

    context 'with attribute ending criteria' do
      let(:group_by) { 'satellites.radius' }
      it { is_expected.to be true }
    end

    context 'with relation ending criteria' do
      let(:group_by) { 'satellites' }
      it { is_expected.to be false }
    end

    context 'with unkown value in criteria' do
      let(:group_by) { 'blah[]' }
      it { is_expected.to be false }
    end
  end
end

