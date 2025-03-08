module Graphiti::ActiveGraph::Extensions::Resources
  module PayloadCobinable
    extend ActiveSupport::Concern

    class_methods do
      def combine(attributes, relationships)
        attributes.merge(relationship_attributes(relationships))
      end

      def relationship_attributes(relationships)
        relationships.map { |k, v| [k, extract_ids(v)] }.to_h
      end

      def extract_ids(object)
        object.is_a?(Array) ? object.map { |o| extract_ids(o) } : object[:attributes][:id]
      end

      def remove_undeclared_attributes(attr_map)
        permitted_attrs = all_attributes.keys
        attr_map.select! { |attr_name, _value| permitted_attrs.include?(attr_name.to_sym) }
      end
    end
  end
end
