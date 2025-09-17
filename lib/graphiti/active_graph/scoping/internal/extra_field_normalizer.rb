module Graphiti::ActiveGraph
  module Scoping
    module Internal
      class ExtraFieldNormalizer

        def initialize(extra_fields)
          @extra_fields = extra_fields
          @extra_includes = []
        end

        def normalize(resource, normalized_includes)
          return [] if @extra_fields.blank?

          collect_extra_field_paths(resource, normalized_includes)
          @extra_includes.uniq
        end

        private

        def collect_extra_field_paths(resource, normalized_includes, parent_path = [])
          normalized_includes.each do |assoc, nested_assoc|
            assoc_resource = fetch_assoc_resource(resource, assoc)
            next unless assoc_resource

            process_extra_fields_for_assoc(assoc_resource, parent_path, assoc)
            collect_extra_field_paths(assoc_resource, nested_assoc, parent_path + [assoc.to_s]) unless nested_assoc.empty?
          end
        end

        def fetch_assoc_resource(resource, assoc)
          resource.class&.sideload_resource_class(normalized_assoc_name(assoc))&.new
        end

        def normalized_assoc_name(assoc)
          assoc.to_s.split('*').first.to_sym
        end

        def process_extra_fields_for_assoc(assoc_resource, parent_path, assoc)
          return unless @extra_fields.key?(assoc_resource.type)

          Array(@extra_fields[assoc_resource.type]).each do |extra_field|   
            add_preload_paths_for_extra_field(extra_field_config(assoc_resource, extra_field), parent_path, assoc)
          end
        end

        def extra_field_config(assoc_resource, extra_field)
          assoc_resource.class&.config&.dig(:extra_attributes, extra_field)
        end

        def add_preload_paths_for_extra_field(config, parent_path, assoc)
          return unless config && config[:preload]
            
          Array(config[:preload]).each do |preload|
            @extra_includes << construct_preload_path(parent_path, assoc, preload)
          end
        end

        def construct_preload_path(parent_path, assoc, preload)
          (parent_path + [assoc.to_s, preload.to_s]).join('.')
        end
      end
    end
  end
end
