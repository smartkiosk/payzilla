# coding: utf-8

require 'cyberplat_pki'
require 'cgi'

module Payzilla
  module Gateways
    class Cyberplat < Gateway
      include Payzilla::Transports::HTTP

      register_settings %w(host operator point key_password dealer)
      register_attachments %w(private_key public_key)

      def check(payment)
        result = request 'pay_check', payment.gateway_provider_id,
          :SD         => @config.setting_dealer,
          :AP         => @config.setting_point,
          :OP         => @config.setting_operator,
          :SESSION    => "c#{payment.id}",
          :NUMBER     => payment.account,
          :ACCOUNT    => payment.fields['account'],
          :AMOUNT     => 100,
          :AMOUNT_ALL => 100

        return retval(result)
      end

      def pay(payment)
        result = request 'pay', payment.gateway_provider_id, 
          :SD         => @config.setting_dealer,
          :AP         => @config.setting_point,
          :OP         => @config.setting_operator,
          :SESSION    => "p#{payment.id}",
          :NUMBER     => payment.account,
          :ACCOUNT    => payment.fields['account'],
          :AMOUNT     => payment.enrolled_amount,
          :AMOUNT_ALL => payment.paid_amount

        return retval(result)
      end

    private

      def sign(text) 
        @private_key ||= CyberplatPKI::Key.new_private(
          @config.attachment_private_key.read,
          @config.setting_key_password
        )
        @private_key.sign(text)
      end

      def retval(code)
        {:success => (code == "0"), :error => code}
      end

      def request(operation, provider, params)
        if @config.setting_host.blank?           ||
           @config.setting_operator.blank?       ||
           @config.setting_point.blank?          ||
           @config.setting_key_password.blank?   ||
           @config.attachment_private_key.blank? ||
           @config.attachment_public_key.blank?
           return -1001
        end

        begin
          data = params.collect{|k,v| "#{k}=#{v.to_s.encode('cp1251')}"}
          data = data.join("\r\n")
          
          provider_params = provider.split('$')
          url_appendix = provider_params[1] ? "/#{provider_params[1]}" : ''

          url  = "https://#{@config.setting_host}/cgi-bin/#{provider_params[0]}/#{provider_params[0]}_pay_check.cgi#{url_appendix}"
          data = "inputmessage=#{CGI::escape sign(data)}"
          
          result = post url, data, :content_type => 'application/x-www-form-urlencoded'

          result = result.gsub("\r", '')
          result = result.split('BEGIN')[1]
          result = result.split('END')[0]

          logger.debug(result) unless logger.blank?

          result = result.split("\n").map{|x| x.split '='}.select{|x| x[0] == 'ERROR'}.first[1]

          return result
        rescue Errno::ECONNRESET
          return -1000
        rescue Exception => e
          logger.fatal e.to_s unless logger.blank?
          return -1002
        end
      end

    end
  end
end