module Graphiti::ActiveGraph
  module Scoping
    module Internal
      # Determine valid paths specified in filter and sort API params and normalize them for neo4j
      class PathDescriptor
        attr_reader :scope, :path, :attribute, :rel
        delegate :relationship_class, to: :rel, allow_nil: true

        def initialize(scope, rel)
          self.scope = scope
          self.path = []
          self.attribute = :id
          self.rel = rel
          @has_next = true
          @associations_cache = {}
          @path_relationships_cache = nil
        end

        def next?
          @has_next
        end

        def increment(key)
          raise StandardError, "no continuation on path possible" unless next?
          if rel
            increment_from_cache(key)
          else
            increment_from_scope(key)
          end
        end

        def declared_property
          (relationship_class || scope).attributes[attribute]
        end

        def self.parse(scope, path, rel = nil)
          return nil if path.empty?

          path_desc = new(scope, rel)

          while path_desc.next? && path.present?
            path_desc.increment(path.shift)
          end

          path.empty? ? path_desc : nil
        end

        def self.association_for_relationship(associations, key)
          key_class_name = key[:rel_name].classify
          key_assoc_name = key[:rel_name].gsub("_rel", "").freeze

          assocs = associations.select { |_, value|
            value.relationship_class_name == key_class_name || value.name.to_s == key_assoc_name
          }

          (assocs.size == 1) ? assocs.first : nil
        end

        def path_relationships
          @path_relationships_cache ||= path.map { |elm| elm[:rel_name].to_sym }.freeze
        end

        private

        attr_writer :scope, :path, :attribute, :rel

        def increment_from_cache(key)
          rel_name = key[:rel_name]
          target_class_names = rel.target_class_names.map(&:demodulize).map(&:downcase)

          if target_class_names.include?(rel_name)
            self.rel = nil
          else
            final_attribute(rel_name)
          end
        end

        def increment_from_scope(key)
          rel_name_sym = key[:rel_name].to_sym
          associations = cached_associations

          if associations.key?(rel_name_sym)
            advance(key)
          else
            increment_from_rel(self.class.association_for_relationship(associations, key), key)
          end
        end

        def increment_from_rel(entry, key)
          if entry
            advance(rel_name: entry.first.to_s)
            self.rel = entry.last
          else
            final_attribute(key[:rel_name])
          end
        end

        def advance(key)
          path << key
          self.scope = scope.send(key[:rel_name], rel_length: key[:rel_length])
          clear_path_cache
        end

        def final_attribute(key)
          self.attribute = key
          @has_next = false
        end

        def cached_associations
          @associations_cache[scope.object_id] ||= scope.associations
        end

        def clear_path_cache
          @path_relationships_cache = nil
        end
      end
    end
  end
end
