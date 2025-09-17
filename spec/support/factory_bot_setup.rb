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
  extra_attribute :full_post_title, :string do
    "#{author.name} - #{title}"
  end

  has_one :author, link: false
  on_extra_attribute :full_post_title, preload: :author do
    scope.with_association(:author)
  end
end

class AuthorResource < Graphiti::ActiveGraph::Resource
  attribute :id, :uuid
  attribute :name, :string
  extra_attribute :recent_three_post_titles, :array do
    posts.last(3).map(&:title)
  end

  has_many :posts, link: false

  on_extra_attribute :recent_three_post_titles, preload: :posts do
    scope.with_association(:posts)
  end
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
