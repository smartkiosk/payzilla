# coding: utf-8

module Payzilla
  module Gateways
    class Osmp < Gateway
      register_settings %w(client password terminal)

      def check(payment)
        begin
          result = Hash.from_xml checkPaymentRequisites(
            payment.id, 
            643,
            payment.paid_amount,
            payment.enrolled_amount,
            payment.gateway_provider_id,
            payment.account,
            payment.fields
          )
          code = result['response']['providers']['checkPaymentRequisites']['payment']['result'].to_i rescue -1
        rescue Errno::ECONNRESET
          code = -1000
        end

        retval(code)
      end

      def pay(payment)
        begin
          result = Hash.from_xml addOfflinePayment(
            payment.id, 
            643,
            payment.paid_amount,
            payment.enrolled_amount,
            payment.gateway_provider_id,
            payment.account,
            payment.fields
          )
          code = result['response']['providers']['addOfflinePayment']['payment']['result'].to_i
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
              <auth login='#{setting_client}' sign='#{Digest::MD5.hexdigest(setting_password.to_s)}' signAlg='MD5'/>
              <client terminal='#{setting_terminal}' software='Dealer v0' serial='' timezone='GMT+03' />
              #{message}
            </request>"

        url    = URI.parse('http://xml1.osmp.ru/xmlgate/xml.jsp')
        http   = Net::HTTP.new(url.host, url.port)
        result = http.post(url.path, message)

        return result.body
      end

      def checkPaymentRequisites(id, currency, paid_amount, enroll_amount, provider_id, account, fields = {})
        send "
          <providers>
            <checkPaymentRequisites>
              <payment id='#{id}'>
                <extras #{fields} />
                <from currency='#{currency}' amount='#{paid_amount}'/>
                <to currency='#{currency}' service='#{provider_id}' amount='#{enroll_amount}' account='#{account}'/>
                <receipt id='#{id}' date='#{DateTime.now}'/>
              </payment>
            </checkPaymentRequisites>
          </providers>
        "
      end

      def addOfflinePayment(id, currency, paid_amount, enroll_amount, provider_id, account, fields = {})
        fields = fields.map{|k,v| "#{k.gsub('_extra_', '')}='#{v}'"}.join(' ')

        send "
          <providers>
            <addOfflinePayment>
              <payment id='#{id}'>
                <extras #{fields} />
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