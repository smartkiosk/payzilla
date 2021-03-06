require 'payzilla/version'
require 'payzilla/payment'
require 'payzilla/revision'
require 'payzilla/gateways'
require 'payzilla/transports/http'
require 'payzilla/utils/string_file'
require 'encoding/converter.rb' if RUBY_PLATFORM =~ /java/
require 'string.rb'

Dir["#{File.dirname(__FILE__)}/payzilla/gateways/*.rb"].each do |gateway|
  begin
    require gateway
  rescue Exception => e
    puts "WARNING: #{File.basename(gateway)} was not loaded: #{e}"
  end
end

module Payzilla
end
