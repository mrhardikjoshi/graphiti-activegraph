module Graphiti::ActiveGraph
  module Adapters
    class ActiveGraph < ::Graphiti::Adapters::Abstract
      def self.sideloading_classes
        {
          has_many: Graphiti::ActiveGraph::Adapters::ActiveGraph::HasManySideload,
          has_one: Graphiti::ActiveGraph::Adapters::ActiveGraph::HasOneSideload,
          polymorphic_belongs_to: Graphiti::ActiveGraph::Adapters::ActiveGraph::PolymorphicBelongsTo,
          belongs_to: Graphiti::ActiveGraph::Adapters::ActiveGraph::HasOneSideload,
        }
      end

      def base_scope(model)
        model
      end

      def assign_attributes(model_instance, attributes)
        model_instance.before_assign_resource_attr if model_instance.respond_to?(:before_assign_resource_attr)

        # currently there is no possible way to assign association on activegraph without triggering save
        # https://github.com/neo4jrb/activegraph/issues/1445
        # using "=" operator bypasses validations and callbacks in case of associations
        # once above issue is fixed, we can change the below code to assign instead of update

        model_instance.update(attributes)
      end

      def paginate(scope, current_page, per_page, offset)
        offset ||= (current_page - 1) * per_page
        scope.skip(offset).limit(per_page)
      end

      def transaction(_model_class)
        ::ActiveGraph::Base.transaction do
          yield
        end
      end

      def order(scope, attribute, direction, extra_field = false)
        if extra_field
          scope.query.order("#{attribute} #{direction}").proxy_as(scope.model, scope.identity)
        else
          scope.send(resource.relation_resource? ? :rel_order : :order, attribute => direction)
        end
      end

      def count(scope, _attr)
        scope.skip(0).limit(nil).count
      end

      def save(model_instance)
        model_instance.save if model_instance.changed?
        model_instance
      end

      def destroy(model_instance)
        model_instance.destroy
        model_instance
      end

      def resolve(scope, resolve_to_rel = false)
        resolve_to_rel ? scope.to_a(false, true) : scope.to_a
      end

      # def associate_all(parent, children, association_name, association_type)
      #   if association_type == :has_many
      #     if !parent.send(:"#{association_name}").present?
      #       parent.send(:"#{association_name}=", children)
      #     else
      #       parent.send(:"#{association_name}") << children
      #     end
      #   else
      #     parent.send(:"#{association_name}=", children)
      #   end
      # end

      def process_belongs_to(persistence, attributes)
        []
      end

      def process_has_many(persistence, caller_model)
        []
      end

      def persistence_attributes(persistence, attributes)
        rel_attrs = {}
        @persistence = persistence

        del_empty_rels(rel_attrs) unless resource.relation_resource?
        attributes_for_has_one(rel_attrs)
        attributes_for_has_many(rel_attrs)

        attributes.merge rel_attrs
      end

      def associate(parent, child, association_name, type)
      end

      def disassociate(parent, child, association_name, type)
        parent.send(:"#{association_name}=", nil)
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

      private

      def del_empty_rels(rel_attrs)
        relationships = @persistence.instance_variable_get(:@relationships)
        relationships.each do |rel_name, rel_data|
          rel_attrs[rel_name] = nil if rel_data.blank?
        end
      end

      def attributes_for_has_one(rel_attrs)
        @persistence.iterate(only: [:has_one]) do |x|
          process_relationship_attrs(x, rel_attrs, false)
        end
      end

      def attributes_for_has_many(rel_attrs)
        @persistence.iterate(only: [:has_many]) do |x|
          process_relationship_attrs(x, rel_attrs, true)
        end
      end

      def process_relationship_attrs(x, rel_attrs, assign_multiple)
        x[:object] = find_record(x)
        resource = @persistence.instance_variable_get(:@resource)
        meta = @persistence.instance_variable_get(:@meta)
        # Relationship start/end nodes cannot be changed once persisted
        unless meta[:method] == :update && resource.relation_resource?
          if assign_multiple
            rel_attrs[x[:foreign_key]] ||= []
            rel_attrs[x[:foreign_key]] << resource_association_value(x)
          else
            rel_attrs[x[:foreign_key]] = resource_association_value(x)
          end
        end
      end

      def resource_association_value(rel_map)
        if [:destroy, :disassociate].include?(rel_map[:meta][:method]) || rel_map[:attributes].blank?
          nil
        else
          rel_map[:object]
        end
      end

      def find_record(x)
        if Graphiti.config.respond_to?(:allow_sidepost) && !Graphiti.config.allow_sidepost
          id = x.dig(:attributes, :id)
          x[:resource].model.find(id) if id
        else
          x[:object] = x[:resource]
            .persist_with_relationships(x[:meta], x[:attributes], x[:relationships], self, x[:foreign_key])
        end
      end
    end
  end
end
