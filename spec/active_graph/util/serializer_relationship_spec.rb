RSpec.describe Graphiti::ActiveGraph::Util::SerializerRelationship do
  subject { Graphiti::Util::SerializerRelationship.new(resource_class, serializer, sideload) }
  before do
    subject.instance_variable_set(:@object, parent_resource)
    allow(resource_class).to receive(:decorate_record)
  end

  let(:resource_class) { double(:resource_class) }
  let(:serializer) { double(:serializer) }
  let(:sideload) { double(:sideload, association_name: :children, assign_each_proc: assign_each_proc, resource: resource_class) }
  let(:parent_resource) { double(:parent_resource, children: [resource_one, resource_two]) }
  let(:resource_one) { double(:resource) }
  let(:resource_two) { double(:resource) }

  context 'with assign_each_proc' do
    let(:assign_each_proc) { ->(parent) { parent.children.first } }

    describe '#data_proc' do
      it 'returns data from assign_each_proc' do
        expect(subject.data_proc.call(nil)).to eq(resource_one)
      end
    end
  end

  context 'without assign_each_proc is present' do
    let(:assign_each_proc) { nil }

    describe '#data_proc' do
      it 'returns data from association call' do
        expect(subject.data_proc.call(nil)).to eq(parent_resource.children)
      end
    end
  end
end
