class Graphiti::ActiveGraph::Adapters::ActiveGraph::FunctionSideload < Graphiti::ActiveGraph::Adapters::ActiveGraph::HasOneSideload
  class_attribute :function_proc

  def association?
    false
  end

  def self.function_proc(proc)
    self.function_proc = proc
  end
end
