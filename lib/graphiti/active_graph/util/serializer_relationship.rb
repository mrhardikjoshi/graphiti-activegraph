module Graphiti::ActiveGraph
  module Util
    module SerializerRelationship
      def data_proc
        sideload_ref = @sideload
        ->(_) {
          # use custom assigned sideload if it is specified via "assign_each_proc"
          # otherwise retrieve sideload using normal getter on parent object
          custom_assigned_sideload = @object.instance_variable_get("@graphiti_render_#{sideload_ref.association_name}")
          records = if custom_assigned_sideload.blank?
                      @object.public_send(sideload_ref.association_name)
                    else
                      custom_assigned_sideload[:data]
                    end

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
