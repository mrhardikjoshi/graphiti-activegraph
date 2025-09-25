RSpec.describe "resource operations Graphiti::ActiveGraph::Resource", neo4j: true do
  describe ".find" do
    let(:author) { create(:author) }
    let(:params) { {id: author.id} }

    it "fetches the record" do
      expect(AuthorResource.find(params).data).to eq(author)
    end
  end

  describe ".all" do
    let(:author) { create(:author) }
    let(:params) { {filter: {id: author.id}} }

    it "fetches the record" do
      expect(AuthorResource.all(params).data).to contain_exactly(author)
    end
  end

  describe "create" do
    let(:params) {
      {data: {
        type: "authors",
        attributes: {name: FFaker::Book.author}
      }}
    }

    it "creates the record" do
      expect(AuthorResource.build(params).save).to be true
      expect(Author.where(name: params[:data][:attributes][:name]).count).to be 1
    end
  end

  describe "#update_attributes" do
    let(:author) { create(:author) }
    let(:params) {
      {data: {
        id: author.id,
        type: "authors",
        attributes: {name: "Updated Name"}
      }}
    }

    it "updates the record" do
      AuthorResource.find(params).update_attributes
      expect(Author.find(author.id).name).to eq(params[:data][:attributes][:name])
    end
  end

  describe "#destroy" do
    let(:author) { create(:author) }
    let(:params) { {id: author.id} }

    it "removes the record" do
      AuthorResource.find(params).destroy
      expect(Author.where(id: author.id)).to be_empty
    end
  end
end
