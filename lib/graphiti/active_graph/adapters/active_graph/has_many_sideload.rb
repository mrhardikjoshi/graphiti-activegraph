class Graphiti::ActiveGraph::Adapters::ActiveGraph::HasManySideload < Graphiti::Sideload::HasMany
  def default_base_scope
    resource_class.model.all
  end

  def infer_foreign_key
    association_name.to_sym
  end
end
