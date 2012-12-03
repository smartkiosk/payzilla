require 'rest-client'

module Payzilla
  module Transports
    module HTTP
      def resource(url, attributes)
        RestClient::Resource.new url, attributes
      end

      def get(url, params, attributes={})
        logger.info "GET #{url}: #{params.inspect}" unless logger.blank?
        logger.debug attributes.inspect unless logger.blank?
        resource(url, attributes).get(:params => params).to_s
      end

      def post(url, params, attributes={})
        logger.info "POST #{url}: #{params.inspect}" unless logger.blank?
        logger.debug attributes.inspect unless logger.blank?
        resource(url, attributes).post(params).to_s
      end

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