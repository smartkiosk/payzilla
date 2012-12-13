# coding: utf-8

require 'nokogiri'

module Payzilla
  module Gateways
    class Osmp < Gateway
      register_settings %w(client password terminal domain)

      def check(payment)
        begin
          result = Nokogiri::XML checkPaymentRequisites(
            payment.id,
            643,
            payment.paid_amount,
            payment.enrolled_amount,
            payment.gateway_provider_id,
            payment.account,
            payment.fields
          )
          code = Nokogiri::XML(result).css("response").first.attributes["result"].value.to_i rescue -1
        rescue Errno::ECONNRESET
          code = -1000
        end

        retval(code)
      end

      def pay(payment)
        begin
          result = Nokogiri::XML addOfflinePayment(
            payment.id,
            643,
            payment.paid_amount,
            payment.enrolled_amount,
            payment.gateway_provider_id,
            payment.account,
            payment.fields
          )
          code = Nokogiri::XML(result).css("response").first.attributes["result"].value.to_i rescue -1
        rescue Errno::ECONNRESET
          code = -1000
        end

        retval(code)
      end

    private

      def retval(code)
        {:success => (code == "0"), :error => code}
      end

      def send(message)
        message =
            "<?xml version='1.0' encoding='windows-1251'?>
            <request>
              <auth login='#{@config.setting_client}' sign='#{Digest::MD5.hexdigest(@config.setting_password.to_s)}' signAlg='MD5'/>
              <client terminal='#{@config.setting_terminal}' software='Dealer v0' serial='' timezone='GMT+03' />
              #{message}
            </request>"

        url    = URI.parse(@config.setting_domain)
        http   = Net::HTTP.new(url.host, url.port)
        
        
        result = RestClient.post @config.setting_domain, message
                
        #result = http.post(url.path, message)

        logger.debug(result.body) unless logger.blank?
        return result.body
      end

      def checkPaymentRequisites(id, currency, paid_amount, enroll_amount, provider_id, account, fields = {})
        send "
          <providers>
            <checkPaymentRequisites>
              <payment id='#{id}'>
                <from currency='#{currency}' amount='#{paid_amount}'/>
                <to currency='#{currency}' service='#{provider_id}' amount='#{enroll_amount}' account='#{account}'/>
                <receipt id='#{id}' date='#{DateTime.now}'/>
              </payment>
            </checkPaymentRequisites>
          </providers>
        "
      end

      def addOfflinePayment(id, currency, paid_amount, enroll_amount, provider_id, account, fields = {})
        #fields = fields.map{|k,v| "#{k.to_s.gsub('_extra_', '')}='#{v}'"}.join(' ')

        send "
          <providers>
            <addOfflinePayment>
              <payment id='#{id}'>
                <from currency='#{currency}' amount='#{paid_amount}'/>
                <to currency='#{currency}' service='#{provider_id}' amount='#{enroll_amount}' account='#{account}'/>
                <receipt id='#{id}' date='#{DateTime.now}'/>
              </payment>
            </addOfflinePayment>
          </providers>
        "
      end
    end
  end
end
