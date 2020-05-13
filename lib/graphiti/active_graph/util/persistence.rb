module Graphiti::ActiveGraph
  module Util
    module Persistence
      def run
        parents = process_belongs_to(@relationships)
        update_foreign_key_for_parents(parents)

        persisted = persist_object(@meta[:method], all_attributes)
        @resource.decorate_record(persisted)
        assign_temp_id(persisted, @meta[:temp_id])

        associate_parents(persisted, parents)

        associate_children(persisted, @processed_rel) unless @meta[:method] == :destroy

        post_process(persisted, parents)
        post_process(persisted, @processed_rel)
        before_commit = -> { @resource.before_commit(persisted, metadata) }
        add_hook(before_commit, :before_commit)
        after_commit = -> { @resource.after_commit(persisted, metadata) }
        add_hook(after_commit, :after_commit)
        persisted
      end

      def all_attributes
        rel_attrs = {}
        @processed_rel = []

        iterate(only: [:has_many, :has_one]) do |x|
          x[:object] = x[:resource]
            .persist_with_relationships(x[:meta], x[:attributes], x[:relationships], self, x[:foreign_key])

          if [:destroy, :disassociate].include?(x[:meta][:method])
            rel_attrs[x[:foreign_key]] = nil
          else
            rel_attrs[x[:foreign_key]] = x[:object].id
          end

          @processed_rel << x
        end
        @attributes.merge rel_attrs
      end

      def update_foreign_key(parent_object, attrs, x)
      end

      def update_foreign_type
      end

      def update_foreign_key(parent_object, attrs, x)
      end
    end
  end
end

class ::Graphiti::Util::Persistence
  prepend ::Graphiti::ActiveGraph::Util::Persistence
end
