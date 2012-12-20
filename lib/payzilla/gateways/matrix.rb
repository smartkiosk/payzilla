# coding: utf-8

require 'crack'

module Payzilla
  module Gateways
    class Matrix < Gateway
      include Payzilla::Transports::HTTP

      register_settings %w(dealer_id key_password url)
      register_attachments %w(cert key ca)

      def check(payment)
        begin 
          result = send 'process_payment',
            :i_service_id => 2,
            :i_phone => payment.account,
            :i_pamount => payment.enrolled_amount,
            :i_pdate => payment.created_at

          return retval(result['ERROR']['@SQLCODE'], result['PAYMENT_ID'])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        begin
          result = send 'process_payment',
            :i_transaction_id => payment.gateway_payment_id,
            :i_receipt_num => payment.id

          return retval(result['ERROR']['SQLCODE'], result['PAYMENT_ID'])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

    private

      def retval(code, foreign_id=false)
        result = {:success => (code == "0"), :error => code}
        result[:gateway_payment_id] = foreign_id if foreign_id
        result
      end

      def send(operation, params)
        params[:i_dealer_id] = @config.setting_dealer_id

        resource = RestClient::Resource.new(
          "#{@config.setting_url}#{operation}",
          ssl(
            @config.attachment_cert,
            @config.attachment_key,
            @config.setting_key_password,
            @config.attachment_ca
          )
        )

        result = resource.get :params => params
        return Crack::XML.parse(result.to_s)['DEALER_PAYMENT']
      end

    end
  end
end
