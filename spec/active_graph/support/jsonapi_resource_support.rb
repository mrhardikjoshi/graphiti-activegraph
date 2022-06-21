class Model
  def initialize(params = {})
    @__graphiti_serializer =
      defined?(graphiti_serializer) ? graphiti_serializer : "Serializable#{self.class.name}".constantize

    params.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end

  def attributes_map(skip_id: true)
    map = self.class.attributes_list.each_with_object({}) do |attr_name, hash|
      hash[attr_name] = send(attr_name)
    end

    skip_id ? map.except(:id) : map
  end

  def self.attributes_list
    @attributes_list ||= []
  end

  def self.attributes(*attr_names)
    attributes_list.concat(attr_names)

    attr_accessor *attr_names
  end

  def self.relationships(*attr_names)
    attr_accessor *attr_names
  end
end

class Star < Model
  # age - billion years
  attributes :id, :name, :age
  relationships :planets, :satellites
end

class Planet < Model
  # temperature - Kelvin
  attributes :id, :name, :temperature
  relationships :star, :satellites
end

class Satellite < Model
  # radius - Km
  attributes :id, :name, :radius
  relationships :star, :planet
end

class SerializableStar < JSONAPI::Serializable::Resource
  type 'stars'

  attributes :name, :age
  relationship :planets, class: 'SerializablePlanet'
  relationship :satellites, class: 'SerializableSatellite'
end

class SerializablePlanet < JSONAPI::Serializable::Resource
  type 'planets'

  attributes :name, :temperature
  relationship :star, class: 'SerializableStar'
  relationship :satellites, class: 'SerializableSatellite'
end

class SerializableSatellite < JSONAPI::Serializable::Resource
  type 'satellites'

  attributes :name, :radius
  relationship :star, class: 'SerializableStar'
  relationship :planet, class: 'SerializablePlanet'
end
