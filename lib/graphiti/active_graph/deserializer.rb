module Graphiti::ActiveGraph
  module Deserializer
    class Conflict < StandardError
      attr_reader :key, :path_value, :body_value

      def initialize(key, path_value, body_value)
        @key = key
        @path_value = path_value
        @body_value = body_value
      end

      def message
        "Path parameter #{key} with value '#{path_value}' conflicts with payload value '#{body_value}'"
      end
    end

    def initialize(payload, env=nil, model=nil, parent_map=nil)
      super(payload)

      if data.blank? && env && JsonApiNonParsableMiddleware.parsable_content?(env)
        raise ArgumentError, "JSON API payload must contain the 'data' key"
      end

      @params = payload
      @model = model
      @parent_map = parent_map || {}
      @env = env
    end

    def process_relationships(relationship_hash)
      {}.tap do |hash|
        relationship_hash.each_pair do |name, relationship_payload|
          name = name.to_sym
          data_payload = relationship_payload[:data]
          hash[name] = data_payload.nil? ? process_nil_relationship(name) : process_relationship(relationship_payload[:data])
        end
      end
    end

    # change empty relationship as `disassociate` hash so they will be removed
    def process_nil_relationship(name)
      attributes = {}
      method_name = :disassociate

      {
        meta: {
          jsonapi_type: name.to_sym,
          method: method_name
        },
        attributes: attributes,
        relationships: {}
      }
    end

    def meta(action: nil)
      results = super
      return results if action.present? || @env.nil?

      action = case @env['REQUEST_METHOD']
               when 'POST' then :create
               when 'PUT', 'PATCH' then :update
               when 'DELETE' then :destroy
               end

      results[:method] = action
      results
    end

    def add_path_id_relationships!(relationship_hash)
      detect_conflict(:id, @params[:id], attributes[:id])
      path_map.each do |rel_name, path_value|
        body_value = relationships.dig(rel_name, :attributes, :id)
        detect_conflict(rel_name, path_value, body_value)
        relationship_hash[rel_name] =
          {
            data: {
              type: rel_name.to_s,
              id: path_value.to_i
            }
          }
      end
      relationship_hash
    end

    def path_map
      map = @params.select { |key, _| key =~ /_id$/ }.permit!.to_h
      map = filter_keys(map) { |key| key.gsub(/_id$/, '').to_sym }
      map = filter_keys(map) { |key| @parent_map[key] || key }
      map = filter_keys_presence(map) if @model < ActiveGraph::Node
      map
    end

    def filter_keys_presence(map)
      filter_keys(map) { |key| presence(key) || presence(key.to_s.pluralize.to_sym) }
    end

    def filter_keys(map)
      map.map { |key, v| [yield(key), v] }.select(&:first).to_h
    end

    def presence(key)
      key if @model.associations.include?(key)
    end

    def detect_conflict(key, path_value, body_value)
      raise Conflict.new(key, path_value, body_value) if body_value && body_value != path_value
    end
  end
end
