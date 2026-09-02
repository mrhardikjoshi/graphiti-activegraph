RSpec.describe "Graphiti 1.13 relationship guards", neo4j: true do
  let(:resource_class) do
    Class.new(Graphiti::ActiveGraph::Resource) do
      self.model = Author
      self.type = :guarded_authors

      attribute :id, :uuid
      attribute :name, :string

      def self.name
        "GuardedAuthorResource"
      end

      def allow_posts?
        context.allow_posts
      end

      has_many :posts, readable: :allow_posts?, link: false
    end
  end

  let!(:author) { create(:author, :with_post) }

  def render_with_guard(allow_posts)
    Graphiti.with_context(OpenStruct.new(allow_posts: allow_posts), :index) do
      JSON.parse(resource_class.all(filter: {id: author.id}, include: "posts").to_jsonapi)
    end
  end

  it "renders and resolves the relationship when the guard passes" do
    payload = render_with_guard(true)

    expect(payload.dig("data", 0, "relationships")).to have_key("posts")
    expect(payload.fetch("included").length).to eq(1)
  end

  it "does not render or resolve the relationship when the guard fails" do
    payload = render_with_guard(false)

    expect(payload.dig("data", 0, "relationships").to_h).not_to have_key("posts")
    expect(payload).not_to have_key("included")
  end
end
