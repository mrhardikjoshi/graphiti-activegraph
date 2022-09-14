lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphiti/active_graph/version"

Gem::Specification.new do |spec|
  spec.name          = "graphiti-activegraph"
  spec.version       = Graphiti::ActiveGraph::VERSION
  spec.authors       = ["Hardik Joshi"]
  spec.email         = ["hardikjoshi1991@gmail.com"]

  spec.summary       = "Easily build jsonapi.org-compatible APIs for GraphDB"
  spec.homepage      = "https://github.com/mrhardikjoshi/graphiti-activegraph"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "graphiti", ">= 1.2.0"
  spec.add_dependency "activegraph", ">= 11.1.0.alpha.1"
  spec.add_dependency "zeitwerk"

  spec.add_development_dependency "faraday", "~> 0.15"
  spec.add_development_dependency "kaminari", "~> 0.17"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "graphiti_spec_helpers", "1.0.beta.4"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "rspec", "~> 3.9.0"
end
