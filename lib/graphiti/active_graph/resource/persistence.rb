module Graphiti::ActiveGraph
  module Resource
    module Persistence
      def update(update_params, meta = nil)
        model_instance = nil
        id = update_params[:id]
        update_params = update_params.except(:id)

        run_callbacks :persistence, :update, update_params, meta do
          run_callbacks :attributes, :update, update_params, meta do |params|
            model_instance = model.find(id)
            call_with_meta(:assign_attributes, model_instance, params, meta)
            model_instance
          end

          run_callbacks :save, :update, model_instance, meta do
            model_instance = call_with_meta(:save, model_instance, meta)
          end
        end

        model_instance
      end
    end
  end
end

module ::Graphiti::Resource::Persistence
  prepend ::Graphiti::ActiveGraph::Resource::Persistence
end
