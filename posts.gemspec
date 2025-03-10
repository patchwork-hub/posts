# frozen_string_literal: true

require_relative "lib/posts/version"

Gem::Specification.new do |spec|
  spec.name = "posts"
  spec.version = Posts::VERSION
  spec.authors       = ["SithuBo"]
  spec.email         = ["sithubo.stb97@gmail.com"]

  spec.summary       = "Overrides MAX_CHARS in Mastodon's StatusLengthValidator"
  spec.description   = "A custom gem to dynamically override the MAX_CHARS constant in Mastodon's StatusLengthValidator class based on server settings."
  spec.homepage      = "https://www.joinpatchwork.org/"

  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 8.0"
  spec.add_dependency "byebug"
end
