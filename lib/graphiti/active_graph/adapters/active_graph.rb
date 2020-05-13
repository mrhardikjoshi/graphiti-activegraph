module Graphiti::ActiveGraph
  module Adapters
    class ActiveGraph < ::Graphiti::Adapters::Abstract
      require "graphiti/active_graph/adapters/active_graph/has_many_sideload"
      require "graphiti/active_graph/adapters/active_graph/has_one_sideload"

      def self.sideloading_classes
        {
          has_many: Graphiti::ActiveGraph::Adapters::ActiveGraph::HasManySideload,
          has_one: Graphiti::ActiveGraph::Adapters::ActiveGraph::HasOneSideload
        }
      end

      def apply_includes_on_scope(scope, sideloads)
        scope.with_associations(sideloads)
      end

      def base_scope(model)
        model.all
      end

      def paginate(scope, current_page, per_page)
        scope
      end

      def transaction(_model_class)
        ::ActiveGraph::Base.run_transaction do
          yield
        end
      end

      def order(scope, attribute, direction)
        scope.order(attribute => direction)
      end

      def count(scope, _attr)
        scope.count
      end

      def save(model_instance)
        model_instance.save
        model_instance
      end

      def destroy(model_instance)
        model_instance.destroy
        model_instance
      end

      def resolve(scope)
        scope.to_a
      end

      def associate_all(parent, children, association_name, association_type)
        if association_type == :has_many
          if !parent.send(:"#{association_name}").present?
            parent.send(:"#{association_name}=", children)
          else
            parent.send(:"#{association_name}") << children
          end
        else
          parent.send(:"#{association_name}=", children)
        end
      end

      def clear_active_connections!
      end

      def filter_eq(scope, attribute, value)
        scope.where(attribute => value)
      end
      alias filter_integer_eq filter_eq
      alias filter_float_eq filter_eq
      alias filter_big_decimal_eq filter_eq
      alias filter_date_eq filter_eq
      alias filter_boolean_eq filter_eq
      alias filter_uuid_eq filter_eq
      alias filter_enum_eq filter_eq

      def filter_not_eq(scope, attribute, value)
        scope.where_not(attribute => value)
      end
      alias filter_integer_not_eq filter_not_eq
      alias filter_float_not_eq filter_not_eq
      alias filter_big_decimal_not_eq filter_not_eq
      alias filter_date_not_eq filter_not_eq
      alias filter_boolean_not_eq filter_not_eq
      alias filter_uuid_not_eq filter_not_eq
      alias filter_enum_not_eq filter_not_eq
    end
  end
end
