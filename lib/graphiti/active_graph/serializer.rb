module Graphiti::ActiveGraph
  module Serializer
    def jsonapi_resource_class
      if polymorphic?
        "#{jsonapi_type.to_s.singularize.camelize}Resource".constantize
      else
        @resource.class
      end
    end

    def resource_class_name
      @_type.to_s.singularize.camelize
    end
  end
end
