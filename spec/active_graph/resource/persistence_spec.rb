RSpec.describe Graphiti::ActiveGraph::Resource::Persistence do
  it 'is included in Graphiti::Scoping::Filter' do
    expect(Graphiti::Resource < described_class).to be true
  end

  it 'override #find_filter method of Graphiti::Scoping::Filter' do
    expect(Graphiti::Resource.instance_method(:update).owner).to be(described_class)
  end
end
