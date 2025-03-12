require 'factory_bot'
require 'ffaker'

class Post
  include ActiveGraph::Node
  id_property :neo_id
  property :title, type: String
  property :body, type: String

  has_one :out, :author, type: :author, model_class: :Author
end

class Author
  include ActiveGraph::Node
  id_property :neo_id
  property :name, type: String

  has_many :in, :posts, origin: :author
end

class PostResource < Graphiti::ActiveGraph::Resource
  attribute :id, :uuid
  attribute :title, :string
  attribute :body, :string

  has_one :author, link: false
end

class AuthorResource < Graphiti::ActiveGraph::Resource
  attribute :id, :uuid
  attribute :name, :string

  has_many :posts, link: false
end

FactoryBot.define do
  factory :author do
    name { FFaker::Book.author }

    factory :with_post do
      posts { [create(:post)] }
    end
  end

  factory :post do
    title { FFaker::Book.title }
    body { FFaker::Book.description }

    factory :with_author do
      author { create(:author) }
    end
  end
end
