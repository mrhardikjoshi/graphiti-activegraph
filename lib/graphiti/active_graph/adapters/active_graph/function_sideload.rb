class Graphiti::ActiveGraph::Adapters::ActiveGraph::FunctionSideload < Graphiti::ActiveGraph::Adapters::ActiveGraph::HasOneSideload
  class_attribute :function_proc, :param_proc

  def association?
    false
  end
end
