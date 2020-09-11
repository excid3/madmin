$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "madmin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "madmin"
  spec.version     = Madmin::VERSION
  spec.authors     = ["Chris Oliver", "Andrew Fomera"]
  spec.email       = ["excid3@gmail.com", "andrew@zerlex.net"]
  spec.homepage    = "https://github.com/excid3/madmin"
  spec.summary     = "A modern admin for Ruby on Rails apps"
  spec.description = "It's an admin, obviously."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency "rails", "~> 6.0.3", ">= 6.0.3.3"

  spec.add_development_dependency "sqlite3"
end
