describe Graphiti::ActiveGraph::JsonapiExt::IncludeDirective do
  describe '#new' do
    subject { described_class.new(includes) }

    context 'when a' do
      let(:includes) { 'a' }
      it 'initializes' do
        expect(subject.to_hash).to eq(a: {})
      end
    end

    context 'when a*' do
      let(:includes) { 'a*' }
      it 'initializes' do
        expect { subject.to_hash }.not_to raise_error
        is_expected.to be_present
        expect(subject.length).to be_nil
        expect(subject.keys).to eq([:a])
        expect(subject[:a].keys).to eq([:a])
        expect(subject[:a].length).to eq('')
        expect(subject[:a][:a]).to eq subject[:a]
      end
    end

    context 'when limited a*2' do
      let(:includes) { 'a*2' }
      it 'initializes' do
        expect { subject.to_hash }.not_to raise_error
        is_expected.to be_present
        expect(subject.length).to be_nil
        expect(subject.keys).to eq([:a])
        expect(subject[:a].keys).to eq([:a])
        expect(subject[:a].length).to eq 1
      end
    end

    context 'when limited a*3' do
      let(:includes) { 'a*3' }
      it 'initializes' do
        expect { subject.to_hash }.not_to raise_error
        is_expected.to be_present
        expect(subject.length).to be_nil
        expect(subject.keys).to eq([:a])
        expect(subject[:a].keys).to eq([:a])
        expect(subject[:a].length).to eq 2
        expect(subject[:a][:a].length).to eq 1
        expect(subject[:a][:a].keys).to eq([:a])
        expect(subject[:a][:a][:a].length).to eq 0
        expect(subject[:a][:a][:a].keys).to be_empty
      end
    end
  end
end
