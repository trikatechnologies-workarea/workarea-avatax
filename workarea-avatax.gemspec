$:.push File.expand_path("../lib", __FILE__)

require "workarea/avatax/version"

Gem::Specification.new do |s|
  s.name        = "workarea-avatax"
  s.version     = Workarea::Avatax::VERSION
  s.authors     = ["Adam Clarke", "Bryan Alexander"]
  s.email       = ["balexander@workarea.com"]
  s.summary     = "Avalara Tax Plugin for the Workarea Ecommerce Platform"
  s.description = "Avatax is a service for sales tax calculation and compliance"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.required_ruby_version = ">= 2.2.2"

  # todo 3.0.7 when its releases
  s.add_dependency "workarea", "~> 3.x", ">= 3.0.6"

  # vendored avatax gem dependencies
  s.add_dependency "faraday",            ">= 0.10"
  s.add_dependency "faraday_middleware", ">= 0.10"
  s.add_dependency "multi_json",         ">= 1.0.3"
  s.add_dependency "hashie",             ">= 3.0.0"
end
