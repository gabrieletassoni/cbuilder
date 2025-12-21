require_relative "lib/cbuilder/version"

Gem::Specification.new do |spec|
  spec.name        = "cbuilder"
  spec.version     = Cbuilder::VERSION
  spec.authors = ["AlchemicIT"]
  spec.email = ["gabrieletassoni@alchemic.it"]
  spec.homepage = "https://github.com/gabrieletassoni/cbuilder"
  spec.summary = "Models and API logic for keeping info about prifiles for Army Building"
  spec.description = "Models and API logic for keeping info about profiles for Army Building of Confrontation 5 Armies."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.homepage = "https://github.com/gabrieletassoni/cbuilder"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency 'model_driven_api', '~> 3.1'
  spec.add_dependency 'thecore_ui_rails_admin', '~> 3.2'
end

