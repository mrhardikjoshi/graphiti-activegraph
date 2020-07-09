module Graphiti::ActiveGraph
  module Util
    module Persistence
      # def run
      #   parents = process_belongs_to(@relationships)
      #   update_foreign_key_for_parents(parents)

      #   persisted = persist_object(@meta[:method], all_attributes)
      #   @resource.decorate_record(persisted)
      #   assign_temp_id(persisted, @meta[:temp_id])

      #   associate_parents(persisted, parents)

      #   associate_children(persisted, @processed_rel) unless @meta[:method] == :destroy

      #   post_process(persisted, parents)
      #   post_process(persisted, @processed_rel)
      #   before_commit = -> { @resource.before_commit(persisted, metadata) }
      #   add_hook(before_commit, :before_commit)
      #   after_commit = -> { @resource.after_commit(persisted, metadata) }
      #   add_hook(after_commit, :after_commit)
      #   persisted
      # end

      # def all_attributes
      #   rel_attrs = {}
      #   @processed_rel = []

      #   process_has_one(rel_attrs)
      #   process_has_many(rel_attrs)

      #   @attributes.merge rel_attrs
      # end

      # def process_has_one(rel_attrs)
      #   iterate(only: [:has_one]) do |x|
      #     process_relationship_attrs(x, rel_attrs, false)
      #   end
      # end

      # def process_has_many(rel_attrs)
      #   iterate(only: [:has_many]) do |x|
      #     process_relationship_attrs(x, rel_attrs, true)
      #   end
      # end

      # def process_relationship_attrs(x, rel_attrs, assign_multiple)
      #   x[:object] = x[:resource]
      #     .persist_with_relationships(x[:meta], x[:attributes], x[:relationships], self, x[:foreign_key])

      #   # Relationship start/end nodes cannot be changed once persisted
      #   unless @meta[:method] == :update && @resource.relation_resource?
      #     if assign_multiple
      #       rel_attrs[x[:foreign_key]] ||= []
      #       rel_attrs[x[:foreign_key]] << resource_association_value(x)
      #     else
      #       rel_attrs[x[:foreign_key]] = resource_association_value(x)
      #     end
      #   end

      #   @processed_rel << x
      # end

      # def resource_association_value(rel_map)
      #   if [:destroy, :disassociate].include?(rel_map[:meta][:method])
      #     nil
      #   else
      #     rel_map[:object]
      #   end
      # end

      # def update_foreign_key(parent_object, attrs, x)
      # end

      # def update_foreign_type
      # end
    end
  end
end

class ::Graphiti::Util::Persistence
  prepend ::Graphiti::ActiveGraph::Util::Persistence
end
