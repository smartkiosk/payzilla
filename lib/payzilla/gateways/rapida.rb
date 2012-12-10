# coding: utf-8

require 'crack'
require 'nokogiri'

module Payzilla
  module Gateways
    class Rapida < Gateway
      include Payzilla::Transports::HTTP

      can_list_providers
      register_settings %w(url key_password)
      register_attachments %w(cert key ca)

      def providers
        return retval(-1001) if settings_miss?

        begin
          providers = request("getfee")
          providers = providers['rapida']
          result    = providers

          return retval("0", result)
        rescue Errno::ECONNRESET
          return retval(-1000)
        rescue Exception => e
          logger.fatal e.to_s unless logger.blank?
          return retval(-1002)
        end
      end

      def check(payment)
        return retval(-1001) if settings_miss?

        begin
          result = request "check", terminal(payment).merge(
            :PaymExtId  => payment.id,
            :PaymSubjTp => payment.gateway_provider_id,
            :Amount     => 100,
            :Params     => fields(payment),
            :FeeSum     => 10
          )

          if result['Response']['Result'] == 'OK'
            result['Response']['ErrCode'] = 0
          else
            result['Response']['ErrCode'] = -1002 if result['Response']['ErrCode'].blank?
          end

          return retval(result['Response']['ErrCode'])
        rescue Errno::ECONNRESET
          return retval(-1000)
        rescue Exception => e
          logger.fatal e.to_s unless logger.blank?
          return retval(-1002)
        end
      end

      def pay(payment)
        return retval(-1001) if settings_miss?

        begin
          result = request "payment", terminal(payment).merge(
            :PaymExtId  => payment.id,
            :PaymSubjTp => payment.gateway_provider_id,
            :Amount     => payment.enrolled_amount,
            :Params     => fields(payment),
            :FeeSum     => payment.commission_amount
          )

          if result['Response']['Result'] == 'OK'
            result['Response']['ErrCode'] = 0
          else
            result['Response']['ErrCode'] = -1002 if result['Response']['ErrCode'].blank?
          end

          return retval(result['Response']['ErrCode'])
        rescue Errno::ECONNRESET
          return retval(-1000)
        rescue Exception => e
          logger.fatal e.to_s unless logger.blank?
          return retval(-1002)
        end
      end

    private

      def settings_miss?
        @config.attachment_cert.blank?  ||
        @config.attachment_key.blank?
      end

      def terminal(payment)
        return {
          :TermType => payment.terminal_id.blank? ? '001-07' : '003-07',
          :TermId   => payment.terminal_id.blank? ? payment.user_id : payment.terminal_id
        }
      end

      def fields(payment)
        fields = payment.fields || {}
        fields.collect{|k,v| "#{k}+#{v}"}.join(';')
      end

      def retval(code, data=nil)
        result = {:success => (code.to_s == "0"), :error => code}
        result[:data] = data unless data.blank?

        result
      end

      def request(method, params={})
        params[:function] = method
        ssl_conf = ssl(
                   @config.attachment_cert,
                   @config.attachment_key,
                   @config.setting_key_password,
                   @config.attachment_ca
                 )

        if RUBY_PLATFORM =~ /java/
          JHTTPClient.new("certificates/rapida.truststore", "123456",
                         @config.setting_url)
        else
          result = get @config.setting_url, params, ssl_conf
        end

        logger.debug(dump_xml result) unless logger.blank?
        return Crack::XML.parse(result)
      end
    end
  end
end
