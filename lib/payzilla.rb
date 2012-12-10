require 'payzilla/version'
require 'payzilla/payment'
require 'payzilla/revision'
require 'payzilla/gateways'
require 'payzilla/transports/http'
require 'payzilla/utils/string_file'
require 'string.rb'

if RUBY_PLATFORM =~ /java/
  require 'encoding/converter.rb'
  Dir["#{File.dirname(__FILE__)}/apache_httpclient/*.jar"].each do |jar|
    begin
      require jar
    rescue Exception => e
      puts "WARNING: #{File.basename(gateway)} was not loaded: #{e}"
    end
  end
  require 'jhttpclient.rb'
end

Dir["#{File.dirname(__FILE__)}/payzilla/gateways/*.rb"].each do |gateway|
  begin
    require gateway
  rescue Exception => e
    puts "WARNING: #{File.basename(gateway)} was not loaded: #{e}"
  end
end

module Payzilla
end
