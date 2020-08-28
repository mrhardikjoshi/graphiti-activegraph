require 'graphiti'
require 'zeitwerk'

# Workaround for missing zeitwerk support as of jruby-9.2.13.0
module Graphiti
  module ActiveGraph
    module Scoping
    end
    module Adapters
    end
    module Util
    end
  end
end
# End workaround

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect 'version' => 'VERSION'
loader.ignore(File.expand_path('graphiti-activegraph.rb', __dir__))
loader.setup

Graphiti::Resource::Persistence.prepend Graphiti::ActiveGraph::Resource::Persistence
Graphiti::Scoping::Filter.prepend Graphiti::ActiveGraph::Scoping::Filter
Graphiti::Scoping::Filterable.prepend Graphiti::ActiveGraph::Scoping::Filterable
Graphiti::Util::SerializerRelationship.prepend Graphiti::ActiveGraph::Util::SerializerRelationship
Graphiti::Deserializer.prepend Graphiti::ActiveGraph::Deserializer
Graphiti::Query.prepend Graphiti::ActiveGraph::Query
Graphiti::Resource.prepend Graphiti::ActiveGraph::ResourceInstanceMethods
Graphiti::Resource.extend Graphiti::ActiveGraph::Resource
Graphiti::ResourceProxy.prepend Graphiti::ActiveGraph::ResourceProxy
Graphiti::Runner.prepend Graphiti::ActiveGraph::Runner
Graphiti::Scope.prepend Graphiti::ActiveGraph::SideloadResolve
