require 'active_support'
require 'active_graph'

# Workaround for jruby prepend issue https://github.com/jruby/jruby/issues/6971
module Graphiti
  module ActiveGraph
  end
  module Scoping
  end
end
require 'graphiti/scoping/filterable'
require 'graphiti/resource/persistence'
require 'graphiti/resource/interface'
# End workaround for jruby prepend issue

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.inflector.inflect 'version' => 'VERSION'
loader.ignore(File.expand_path('graphiti-activegraph.rb', __dir__))
loader.setup

Graphiti::Scoping::Filterable.prepend Graphiti::ActiveGraph::Scoping::Filterable
Graphiti::Resource::Persistence.prepend Graphiti::ActiveGraph::Resources::Persistence
Graphiti::Resource::Interface::ClassMethods.prepend Graphiti::ActiveGraph::Resources::Interface::ClassMethods
require 'graphiti'
Graphiti::Scoping::Filter.prepend Graphiti::ActiveGraph::Scoping::Filter
Graphiti::Serializer.prepend Graphiti::ActiveGraph::Serializer
Graphiti::Util::SerializerRelationship.prepend Graphiti::ActiveGraph::Util::SerializerRelationship
Graphiti::Util::SerializerAttribute.prepend Graphiti::ActiveGraph::Util::SerializerAttribute
Graphiti::Util::RelationshipPayload.prepend Graphiti::ActiveGraph::Util::RelationshipPayload
Graphiti::Query.prepend Graphiti::ActiveGraph::Query
Graphiti::ResourceProxy.prepend Graphiti::ActiveGraph::ResourceProxy
Graphiti::Runner.prepend Graphiti::ActiveGraph::Runner
Graphiti::Scope.prepend Graphiti::ActiveGraph::SideloadResolve
Graphiti::Configuration.include Graphiti::SidepostConfiguration
Graphiti::RequestValidators::Validator.prepend Graphiti::ActiveGraph::RequestValidators::Validator

unless RUBY_PLATFORM == 'java'
  Graphiti.prepend Graphiti::ActiveGraph::Extensions::Context
end

# JSONAPI extensions
JSONAPI::Serializable::Resource.prepend Graphiti::ActiveGraph::JsonapiExt::Serializable::ResourceExt
