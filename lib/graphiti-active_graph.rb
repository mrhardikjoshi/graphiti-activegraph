require "graphiti"
require 'graphiti/active_graph/version'

if defined?(ActiveGraph)
  require 'graphiti/active_graph/adapters/active_graph.rb'
  require 'graphiti/active_graph/resource'
  # require 'graphiti/active_graph/scope'
  require 'graphiti/active_graph/runner'
  require 'graphiti/active_graph/resource_proxy'
  require 'graphiti/active_graph/util/persistence'
  # # require 'graphiti/active_graph/persistence'
end
