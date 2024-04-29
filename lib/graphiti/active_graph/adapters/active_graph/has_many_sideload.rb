class Graphiti::ActiveGraph::Adapters::ActiveGraph::HasManySideload < Graphiti::Sideload::HasMany
  include Graphiti::ActiveGraph::Adapters::ActiveGraph::Sideload

  def default_value_when_empty
    []
  end
end
