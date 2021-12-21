RSpec.describe Graphiti::ActiveGraph::Scoping::Filterable do
  it 'is included in Graphiti::Scoping::Filter' do
    expect(Graphiti::Scoping::Filter < described_class).to be true
  end

  it 'override #find_filter method of Graphiti::Scoping::Filter' do
    expect(Graphiti::Scoping::Filter.instance_method(:find_filter!).owner).to be(described_class)
  end
end
