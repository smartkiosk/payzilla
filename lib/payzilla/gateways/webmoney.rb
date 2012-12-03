# coding: utf-8

require 'webmoney'
require 'gyoku'
require 'crack'

module Payzilla
  module Gateways
    class Webmoney < Gateway
      class Signer
        include ::Webmoney
      end

      register_settings %w(wmid kiosk_id key_password)
      register_attachments %w(cert key)
      register_switches %w(test_mode)

      def check(payment)
        begin 
          result = send 'XMLBankGatewaysInputAccess1',
            :sign => signer.sign("#{@config.setting_wmid}100#{payment.fields['purse']}#{payment.fields['phone']}#{@config.setting_kiosk_id}"),
            :'attributes!' => {
              :sign => {
                :type => 1
              }
            },
            :payment => {
              :price => 100,
              :purse => payment.fields['purse'],
              :phone => payment.fields['phone']
            }

          return retval(result['retval'])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        begin 
          result = send 'XMLBankGatewaysInput',
            :sign => signer.sign("#{payment.id}#{payment.enrolled_amount}#{payment.id}#{payment.fields['purse']}#{payment.fields['phone']}"),
            :attributes! => {
              :sign => {
                :type => 1
              },
              :payment => {
                :id => payment.id,
                :test => @config.switch_test_mode
              }
            },
            :payment => {
              :name => payment.fields['name'],
              :passport_serie => payment.fields['passport_serie'],
              :passport_number => payment.fields['passport_number'],
              :passport_date => payment.fields['passport_date'],
              :price => payment.enrolled_amount,
              :purse => payment.fields['purse'],
              :cheque => payment.id,
              :date => payment.created_at,
              :kiosk_id => @config.setting_kiosk_id,
              :phone => payment.fields['phone']
            }

          return retval(result['retval'], result['payment']['wmtranid'])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

    private

      def signer
        if @signer.blank?
          cert = OpenSSL::X509::Certificate.new(File.read @config.attachment_cert)
          key  = OpenSSL::PKey::RSA.new(File.read(@config.attachment_key), @config.setting_key_password)

          @signer = Signer.new :wmid => @config.setting_wmid, :cert => cert, :key => key
        end

        @signer
      end

      def retval(result, foreign_id = false)
        result = {:success => result.to_s == "0", :error => result}
        result[:gateway_payment_id] = foreign_id if foreign_id
        return result
      end

      def send(operation, params)
        params[:wmid] = @config.setting_wmid
        resource = RestClient::Resource.new("https://w3s.guarantee.ru/#{operation}.aspx")

        params = Gyoku.xml(:'w3s.request' => params)
        result = resource.post params, :content_type => 'application/xml'

        return Nori.parse(result.to_s)
      end

    end
  end
end