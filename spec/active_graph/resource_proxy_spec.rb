RSpec.describe Graphiti::ResourceProxy do
  let(:resource) { double(:resource) }
  let(:scope) { double(:scope) }
  let(:query) { double(:query) }

  it "preserves Graphiti cache options alongside preloaded data" do
    proxy = described_class.new(
      resource,
      scope,
      query,
      cache: true,
      cache_expires_in: 60,
      cache_tag: :cache_partition,
      preloaded: []
    )

    expect(proxy.cache).to be(true)
    expect(proxy.cache_expires_in).to eq(60)
    expect(proxy.cache_tag).to eq(:cache_partition)
    expect(proxy.preloaded).to eq([])
  end

  it "uses the configured resource cache tag" do
    resource = double(:resource, cache_partition: "tenant-42")
    proxy = described_class.new(resource, scope, query, cache_tag: :cache_partition)

    expect(proxy.resource_cache_tag).to eq("tenant-42")
  end
end

RSpec.describe Graphiti::Runner do
  it "forwards Graphiti 1.13 scope and cache options" do
    runner = described_class.allocate
    resource = double(:resource, base_scope: :base_scope)
    scope = double(:scope)
    query = double(:query)

    allow(runner).to receive_messages(
      params: {},
      jsonapi_resource: resource,
      query: query,
      deserialized_payload: nil
    )
    expect(runner).to receive(:jsonapi_scope)
      .with(:base_scope, hash_including(bypass_required_filters: true))
      .and_return(scope)

    proxy = runner.proxy(
      nil,
      bypass_required_filters: true,
      cache: true,
      cache_expires_in: 60,
      cache_tag: :cache_partition
    )

    expect(proxy.cache).to be(true)
    expect(proxy.cache_expires_in).to eq(60)
    expect(proxy.cache_tag).to eq(:cache_partition)
  end
end

RSpec.describe "Graphiti::ActiveGraph::Resource.wrap", neo4j: true do
  let(:author) { create(:author) }

  it "returns and decorates supplied records without resolving the scope" do
    proxy = AuthorResource.wrap([author])

    expect(proxy.scope).not_to receive(:resolve)
    expect(proxy.data).to eq([author])
    expect(author.instance_variable_get(:@__graphiti_serializer)).to eq(AuthorResource.serializer)
  end

  it "rejects a model for a different resource" do
    expect { AuthorResource.wrap(create(:post)) }
      .to raise_error(Graphiti::Errors::InvalidWrapModel)
  end
end
