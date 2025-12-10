# frozen_string_literal: true

require_relative "lib/posts/version"

Gem::Specification.new do |spec|
  spec.name = "posts"
  spec.version = Posts::VERSION
  spec.authors       = ["Aung Kyaw Phyo"]
  spec.email         = ["kiru.kiru28@gmail.com"]

  spec.summary       = "A Ruby on Rails plugin that enhances Mastodon’s posting features with customizable character limits, draft management, quote posts, and automatic ALT text generation."
  spec.description   = "A Ruby on Rails plugin that enhances Mastodon’s posting features with customizable character limits, draft management, quote posts, and automatic ALT text generation."
  spec.homepage      = "https://www.joinpatchwork.org/"

  spec.license       = "AGPL-3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 7.1.1"
  spec.add_dependency "byebug", '~> 11.1'
  spec.add_dependency "annotaterb", '~> 4.13'
  spec.add_dependency 'link_thumbnailer', '~> 3.4'
end
