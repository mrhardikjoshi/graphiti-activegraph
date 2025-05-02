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
        end

        def next?
          @has_next
        end

        def increment(key)
          raise Exception, 'no continuation on path possible' unless next?
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
          path_desc = new(scope, rel)
          path_desc.increment(path.shift) while path_desc.next? && path.present?
          path_desc if path.empty?
        end

        def self.association_for_relationship(associations, key)
          key_class_name = key[:rel_name].classify
          key_assoc_name = key[:rel_name].gsub('_rel', '')
          assocs = associations.find_all { |_, value| value.relationship_class_name == key_class_name || value.name.to_s == key_assoc_name }
          assocs.size == 1 ? assocs.first : nil
        end

        def path_relationships
          path.map { |elm| elm[:rel_name].to_sym }
        end

        private

        attr_writer :scope, :path, :attribute, :rel

        def increment_from_cache(key)
          rel_name = key[:rel_name]
          if rel.target_class_names.map(&:demodulize).map(&:downcase).include?(rel_name)
            self.rel = nil
          else
            final_attribute(rel_name)
          end
        end

        def increment_from_scope(key)
          associations = scope.associations
          if associations.key?(key[:rel_name].to_sym)
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
        end

        def final_attribute(key)
          self.attribute = key
          @has_next = false
        end
      end
    end
  end
end
