require 'rest-client'

module Payzilla
  module Transports
    module HTTP
      # Generate new RestClient resource
      #
      # @param [String] url carrier's server url
      # @param [Hash] attributes additional attributes such as ssl certificate and keys
      # @return [RestClient::Resource] resource, where you can send payment data with GET or POST methods
      def resource(url, attributes)
        RestClient::Resource.new url, attributes
      end

      # Send data via GET method
      #
      # @param [String] url carrier's server url
      # @param [Hash] params data, which would be sent
      # @param [Hash] attributes additional attributes such as ssl certificate and keys
      # @return [String] server response
      def get(url, params, attributes={})
        logger.info "GET #{url}: #{params.inspect}" unless logger.blank?
        logger.debug attributes.inspect unless logger.blank?
        resource(url, attributes).get(:params => params).to_s
      end

      # Send data via POST method
      #
      # @param [String] url carrier's server url
      # @param [Hash] params data, which would be sent
      # @param [Hash] attributes additional attributes such as ssl certificate and keys
      # @return [String] server response
      def post(url, params, attributes={})
        logger.info "POST #{url}: #{params.inspect}" unless logger.blank?
        logger.debug attributes.inspect unless logger.blank?
        resource(url, attributes).post(params).to_s
      end

      # Prepare SSL data to be sent
      #
      # @param [File] cert certificate file, that you should use to access to secure host
      # @param [File] key key file, that you need to use to access to secure host
      # @param [String] password password that used to read encrypted key file
      # @param [File] ca certificate authority file, if it is needed
      def ssl(cert, key, password, ca=false)
        ssl = {
          :ssl_client_cert  =>  OpenSSL::X509::Certificate.new(File.read cert.path),
          :verify_ssl       =>  OpenSSL::SSL::VERIFY_NONE
        }

        unless password.blank?
          ssl[:ssl_client_key] = OpenSSL::PKey::RSA.new(File.read(key.path), password)
        else
          ssl[:ssl_client_key] = OpenSSL::PKey::RSA.new(File.read(key.path))
        end
        ssl[:ssl_ca_file] = ca.path unless ca.blank?

        ssl
      end
    end
  end
end
