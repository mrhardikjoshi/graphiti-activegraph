RSpec.describe Graphiti::ActiveGraph::Scoping::Filterable do
  it "is included in Graphiti::Scoping::Filter" do
    expect(described_class > Graphiti::Scoping::Filter).to be true
  end

  it "override #find_filter method of Graphiti::Scoping::Filter" do
    expect(Graphiti::Scoping::Filter.instance_method(:find_filter!).owner).to be(described_class)
  end
end
