RSpec.describe Graphiti::ActiveGraph::Resources::Persistence do
  it "is included in Graphiti::ActiveGraph::Resource" do
    expect(described_class > Graphiti::ActiveGraph::Resource).to be true
  end

  it "override #find_filter method of Graphiti::ActiveGraph::Resource" do
    expect(Graphiti::ActiveGraph::Resource.instance_method(:update).owner).to be(described_class)
  end
end
