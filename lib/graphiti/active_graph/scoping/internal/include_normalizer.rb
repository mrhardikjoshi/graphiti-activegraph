module Graphiti::ActiveGraph
  module Scoping
    module Internal
      class IncludeNormalizer
        include SparseFieldsEagerloading

        def initialize(resource_class, scope, fields)
          @scope = scope
          @resource_class = resource_class
          @fields = fields
        end

        def normalize(include_hash)
          normalize_includes(@scope, include_hash, @resource_class)
        end

        private

        def normalize_includes(scope, include_hash, resource_class)
          includes_array = include_hash.map do |key, value|
            normalize_include(scope, key, value, resource_class)
          end
          add_relationships_from_sparse_fields(scope, includes_array)
          deep_merge_hashes(includes_array.compact).to_h
        end

        def deep_merge_hashes(includes_array)
          includes_array.each_with_object({}) do |(key, value), mapping|
            mapping[key] = mapping[key] ? mapping[key].deep_merge(value) : value
          end.to_a
        end

        def normalize_include(scope, key, value, resource_class)
          rel_name = rel_name_sym(key)

          if scope.associations.key?(rel_name)
            [key, normalize_includes(scope.send(rel_name), value, find_resource_class(resource_class, rel_name, scope))]
          elsif (custom_eagerload = resource_class&.custom_eagerload(rel_name))
            handle_custom_eagerload(scope, custom_eagerload)
          else
            include_for_rel(scope, rel_name, value, resource_class)
          end
        end

        def handle_custom_eagerload(_scope, custom_eagerload)
          JSONAPI::IncludeDirective.new(custom_eagerload).to_hash
        end

        def include_for_rel(scope, key, value, resource_class)
          return unless association = PathDescriptor.association_for_relationship(scope.associations, rel_name: key.to_s)

          limit_part = Graphiti::ActiveGraph::Util::Transformers::RelationParam.new(value.keys.first).rel_limit
          association_name = :"#{limit_part}#{association.first}"
          normalize_include(scope, association_name, next_non_rel_value(value), resource_class_by_rel(resource_class, association, key, scope))
        end

        def find_resource_class(resource_class, rel_name, scope)
          target_class_name = scope.associations[rel_name]&.target_class&.model_name

          resource_class&.sideload_resource_class(rel_name) ||
            resource_class&.sideload_resource_class(target_class_name&.singular&.to_sym)
        end

        def resource_class_by_rel(resource_class, association, key, scope)
          # in case of rel resource, for finding custom_eagerload defination
          # if current resourceClass defination has direct association defined with opposite node of relResource
          #   then use current resourceClass, (giving direct resourceClass more preference than relResourceClass)
          # else use relResourceClass
          find_resource_class(resource_class, association.first, scope) ? resource_class : resource_class&.sideload_resource_class(rel_name_sym(key))
        end

        def rel_name_sym(key)
          Graphiti::ActiveGraph::Util::Transformers::RelationParam.new(key).rel_name_sym
        end

        def next_non_rel_value(value)
          value.values.first || {}
        end
      end
    end
  end
end
