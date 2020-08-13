module Graphiti::ActiveGraph
  module Util
    module SerializerRelationship
      def data_proc
        sideload_ref = @sideload
        ->(_) {
          records = @object.instance_variable_get("@graphiti_render_#{sideload_ref.association_name}")
          records = @object.public_send(sideload_ref.association_name) if records.nil?

          if records
            if records.respond_to?(:to_ary)
              records.each { |r| sideload_ref.resource.decorate_record(r) }
            else
              sideload_ref.resource.decorate_record(records)
            end

            records
          end
        }
      end
    end
  end
end
