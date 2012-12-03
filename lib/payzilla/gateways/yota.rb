# coding: utf-8

require 'crack'

module Payzilla
  module Gateways
    class Yota < Gateway
      register_settings %w(url key_password)
      register_attachments %w(cert key ca)

      def check(payment)
        begin 
          result = send 'check', 
            :number => payment.account,
            :amount => 100

          return retval(result)
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        begin
          result = send 'payment',
            :number  => payment.account,
            :amount  => 100,
            :receipt => payment.id,
            :date    => payment.created_at

          return retval(result)
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

    private

      def retval(code)
        {:success => (code == "0"), :error => code}
      end

      def send(operation, params)
        params[:action] = operation
        params[:type]   = 1

        resource = RestClient::Resource.new(
          @config.setting_url,
          ssl_settings(
            @config.attachment_cert,
            @config.attachment_key,
            @config.setting_key_password,
            @config.attachment_ca
          )
        )

        result = resource.get :params => params
        return Crack::XML.parse(result.to_s)['response']['code']
      end

    end
  end
end