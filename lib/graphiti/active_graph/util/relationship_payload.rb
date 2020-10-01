module Graphiti::ActiveGraph
  module Util
    module RelationshipPayload
      def payload_for(sideload, relationship_payload)
        type = relationship_payload[:meta][:jsonapi_type]&.to_sym

        # For polymorphic *sideloads*, grab the correct child sideload
        if sideload.resource.type != type && sideload.type == :polymorphic_belongs_to
          sideload = sideload.child_for_type!(type)
        end

        # For polymorphic *resources*, grab the correct child resource
        resource = sideload.resource
        if resource.type != type && resource.polymorphic?
          resource = resource.class.resource_for_type(type).new
        end

        relationship_payload[:meta][:method] ||= :update

        {
          resource: resource,
          sideload: sideload,
          is_polymorphic: sideload.polymorphic_child?,
          primary_key: sideload.primary_key,
          foreign_key: sideload.foreign_key,
          attributes: relationship_payload[:attributes],
          meta: relationship_payload[:meta],
          relationships: relationship_payload[:relationships]
        }
      end
    end
  end
end
