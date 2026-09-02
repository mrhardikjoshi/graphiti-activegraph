RSpec.describe Graphiti::ActiveGraph::Resources::Persistence do
  it 'is included in Graphiti::ActiveGraph::Resource' do
    expect(Graphiti::ActiveGraph::Resource < described_class).to be true
  end

  it 'override #find_filter method of Graphiti::ActiveGraph::Resource' do
    expect(Graphiti::ActiveGraph::Resource.instance_method(:update).owner).to be(described_class)
  end

  describe 'Graphiti 1.13 around_persistence mutation warning', neo4j: true do
    let(:resource_class) do
      Class.new(AuthorResource) do
        self.model = Author
        self.type = :authors

        def self.name
          'MutationWarningAuthorResource'
        end

        around_persistence :mutate_attributes, only: :update

        def mutate_attributes(attributes)
          attributes[:name] = 'changed in hook'
          yield
        end
      end
    end

    let(:author) { create(:author) }
    let(:params) do
      {
        data: {
          id: author.id,
          type: 'authors',
          attributes: { name: 'requested name' }
        }
      }
    end

    it 'retains the mutation and emits Graphiti deprecation guidance' do
      expect(Graphiti::DEPRECATOR).to receive(:warn)
        .with(/around_persistence hook modified the attributes hash before yield \(changed keys: :name\)/)

      resource_class.find(params).update_attributes

      expect(Author.find(author.id).name).to eq('changed in hook')
    end
  end
end
