ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../../../patchwork_web/config/environment', __FILE__)
require 'rspec/rails'

# Load the main app's spec helper
require File.expand_path('../../../../patchwork_web/spec/rails_helper', __FILE__)

# Additional requires for the engine
Dir[Engine.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/fabricators/**/*.rb')].each { |f| require f }

RSpec.configure do |config|

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

end