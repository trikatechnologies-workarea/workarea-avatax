$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "weblinc/avatax/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "weblinc-avatax"
  s.version     = Weblinc::Avatax::VERSION
  s.authors     = ["Adam Clarke", "Mark Anderson"]
  s.email       = ["adam@revelry.co"]
  s.summary     = "Avalara Tax Plugin for the Weblinc Ecommerce Platform"
  s.description = "Avatax is a service for sales tax calculation and compliance"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'weblinc', '~> 0.5.0'
  s.add_dependency 'avatax', '~> 14.4.4'
  s.add_dependency 'mongoid-enum', '~> 0.2.0'
end
