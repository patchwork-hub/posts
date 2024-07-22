# frozen_string_literal: true

module Posts
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    
    def copy_initializer_file
      copy_file "post_initializer.rb", Rails.root + "config/initializers/post.rb"
    end
    
    def rake_db
      rake("posts:install:migrations")
      rake("db:migrate")
    end
    
  end
end