$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "madmin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "madmin"
  spec.version = Madmin::VERSION
  spec.authors = ["Chris Oliver", "Andrea Fomera"]
  spec.email = ["excid3@gmail.com", "afomera@hey.com"]
  spec.homepage = "https://github.com/excid3/madmin"
  spec.summary = "A modern admin for Ruby on Rails apps"
  spec.description = "It's an admin, obviously."
  spec.license = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = ">= 3.2.0"

  spec.add_dependency "rails", ">= 7.0.0"
  spec.add_dependency "pagy", ">= 3.5"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "propshaft"
end
