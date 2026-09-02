module Graphiti::ActiveGraph
  module Resources
    module Persistence
      def update(update_params, meta = nil)
        model_instance = nil
        id = update_params[:id]
        update_params = update_params.except(:id)

        snapshot = attributes_snapshot(:update, update_params) if respond_to?(:attributes_snapshot, true)

        run_callbacks :persistence, :update, update_params, meta do
          if respond_to?(:warn_attributes_mutated_in_around_persistence, true)
            warn_attributes_mutated_in_around_persistence(:update, snapshot, update_params)
          end

          run_callbacks :attributes, :update, update_params, meta do |params|
            model_instance = id ? model.find(id) : self.class._find(id: id).data
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
