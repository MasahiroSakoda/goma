$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "goma/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "goma"
  s.version     = Goma::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Goma."
  s.description = "TODO: Description of Goma."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.1"

  s.add_development_dependency "sqlite3"
end
