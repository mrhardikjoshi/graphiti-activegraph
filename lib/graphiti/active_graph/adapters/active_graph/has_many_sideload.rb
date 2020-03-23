class GraphitiActiveGraph::Adapters::ActiveGraph::HasManySideload < Graphiti::Sideload::HasMany
  def default_base_scope
    resource_class.model.all
  end
end
