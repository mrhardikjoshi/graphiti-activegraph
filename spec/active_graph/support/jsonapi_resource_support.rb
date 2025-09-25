module ModelParent
  def initialize(params = {})
    super
    @__graphiti_serializer =
      defined?(graphiti_serializer) ? graphiti_serializer : "Serializable#{self.class.name}".constantize
  end
end

class Star
  include ActiveGraph::Node

  id_property :neo_id
  include ModelParent

  property :id, type: Integer
  property :name, type: String
  property :age, type: Float # unit billion years

  has_many :in, :planets, type: :planet
  has_many :in, :satellites, type: :satellite
end

class Planet
  include ActiveGraph::Node

  id_property :neo_id
  include ModelParent

  property :id, type: Integer
  property :name, type: String
  property :temperature, type: Integer # unit Kelvin

  has_one :out, :star, type: :planet
  has_many :out, :satellites, type: :satellite
end

class Satellite
  include ActiveGraph::Node

  id_property :neo_id
  include ModelParent

  property :id, type: Integer
  property :name, type: String
  property :radius, type: Integer # radius in Km

  has_one :out, :star, type: :satellite
  has_one :out, :planet, type: :satellite
end

class SerializableStar < JSONAPI::Serializable::Resource
  type "stars"

  attributes :id, :name, :age
  relationship :planets, class: "SerializablePlanet"
  relationship :satellites, class: "SerializableSatellite"
end

class SerializablePlanet < JSONAPI::Serializable::Resource
  type "planets"

  attributes :id, :name, :temperature
  relationship :star, class: "SerializableStar"
  relationship :satellites, class: "SerializableSatellite"
end

class SerializableSatellite < JSONAPI::Serializable::Resource
  type "satellites"

  attributes :id, :name, :radius
  relationship :star, class: "SerializableStar"
  relationship :planet, class: "SerializablePlanet"
end

class PlanetResource < Graphiti::ActiveGraph::Resource
  attribute :id, :integer, writable: false
  attribute :name, :string
  attribute :temperature, :integer
end
