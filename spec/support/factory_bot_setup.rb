require 'factory_bot'
require 'ffaker'

class Post
  include ActiveGraph::Node
  id_property :neo_id
  property :title, type: String
  property :body, type: String

  has_one :out, :author, type: :author, model_class: :Author
  has_many :in, :comments, origin: :post
end

class Comment
  include ActiveGraph::Node
  id_property :neo_id
  property :title, type: String
  property :body, type: String

  has_one :out, :author, type: :author, model_class: :Author
  has_one :out, :post, type: :post, model_class: :Post

  attr_writer :author_activity

  def author_activity
    @author_activity ||= author.comments.count + author.posts.count
  end

  def self.preload_author_activity(comment_ids)
    where(id: comment_ids).with_associations(author: [:posts, :comments]).to_h do |comment|
      author = comment.author
      [comment.id, author.posts.count + author.comments.count]
    end
  end
end

class Author
  include ActiveGraph::Node
  id_property :neo_id
  property :name, type: String

  attr_writer :posts_number

  has_many :in, :posts, origin: :author
  has_many :in, :comments, origin: :author

  def posts_number
    @posts_number ||= posts.count
  end

  def self.preload_posts_number(author_ids)
    where(id: author_ids).with_associations(:posts).to_h { |result| [result.id, result.posts.count] }
  end
end

class PostResource < Graphiti::ActiveGraph::Resource
  attribute :id, :uuid
  attribute :title, :string
  attribute :body, :string
  extra_attribute :full_post_title, :string, preload: :author do
    "#{author.name} - #{title}"
  end

  has_one :author, link: false
  has_many :comments, link: false
end

class CommentResource < Graphiti::ActiveGraph::Resource
  attribute :id, :uuid
  attribute :title, :string
  attribute :body, :string
  extra_attribute :author_activity, :integer

  has_one :author, link: false
  has_one :post, link: false
end

class AuthorResource < Graphiti::ActiveGraph::Resource
  attribute :id, :uuid
  attribute :name, :string
  extra_attribute :recent_three_post_titles, :array, preload: :posts do
    posts.last(3).map(&:title)
  end
  extra_attribute :posts_number, :integer

  has_many :posts, link: false
  has_many :comments, link: false
end

FactoryBot.define do
  factory :author do
    name { FFaker::Book.author }

    trait :with_post do
      posts { [create(:post)] }
    end

    trait :with_two_posts do
      posts { [create(:post), create(:post)] }
    end

    trait :with_post_and_comment do
      posts { [create(:post, :with_comment_and_author)] }
    end
  end

  factory :post do
    title { FFaker::Book.title }
    body { FFaker::Book.description }

    trait :with_author do
      author { create(:author) }
    end

    trait :with_comment do
      comments { create(:comment, :with_author) }
    end

    trait :with_comment_and_author do
      comments { create(:comment, :with_author_and_posts) }
    end
  end

  factory :comment do
    title { FFaker::Book.title }
    body { FFaker::Book.genre }

    trait :with_author do
      author { create(:author) }
    end

    trait :with_author_and_posts do
      author { create(:author, :with_two_posts) }
    end
  end
end
