module Graphiti::ActiveGraph
  module Scoping
    module Internal
      module SparseFieldsEagerloading
        private

        def add_relationships_from_sparse_fields(scope, includes_array)
          return if @fields.blank?

          related_fields(scope.model).each { |field_name| includes_array << process_field(field_name, scope) }
        end

        def process_field(field_name, _scope)
          field_name
        end

        def resource_name_of(model)
          model.model_name.plural.to_sym
        end

        def related_fields(model)
          attr_and_rel_fields = @fields[resource_name_of(model)] || []
          attr_and_rel_fields.select { |field_name| model.associations[field_name] }
        end
      end
    end
  end
end
