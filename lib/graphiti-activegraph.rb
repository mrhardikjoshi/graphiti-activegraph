require "graphiti"
require 'graphiti/active_graph/version'

if defined?(ActiveGraph)
  require 'graphiti/active_graph/adapters/active_graph.rb'
  require 'graphiti/active_graph/resource'
  require 'graphiti/active_graph/scope'
  require 'graphiti/active_graph/runner'
  require 'graphiti/active_graph/resource_proxy'
  require 'graphiti/active_graph/resource/persistence'
  require 'graphiti/active_graph/deserializer'
  require 'graphiti/active_graph/scoping/filterable.rb'
  require 'graphiti/active_graph/scoping/filter'
  require 'graphiti/active_graph/query'
end
