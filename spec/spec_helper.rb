require 'payzilla'
require 'pry'
require 'rspec/expectations'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include RSpec::Matchers
end