class GraphitiActiveGraph::Adapters::ActiveGraph::HasOneSideload < Graphiti::Sideload::HasOne
  def default_base_scope
    resource_class.model.all
  end
end
