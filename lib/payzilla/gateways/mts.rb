require 'crack'
require 'digest/md5'

module Payzilla
  module Gateways
    class Mts < Gateway
      include Payzilla::Transports::HTTP

      requires_revision
      register_settings %w(url agent contract key_password signature_key_password terminal_prefix)
      register_attachments %w(cert key ca signature_key)

      def check(payment)
        return retval(-1001) if settings_miss?

        begin 
          xml = Builder::XmlMarkup.new

          xml.f_01(payment.account, :"xsi:type" => 'espp-constraints:PHN_CODE_fmt_01')
          xml.f_02(100.0)
          xml.f_03(810, :"xsi:type" => 'espp-constraints:CUR_fmt_01')
          xml.f_04(1)
          xml.f_05(terminal(payment))
          xml.f_06(1)
          xml.f_07(@config.setting_agent)
          xml.f_08(@config.setting_contract)
          xml.f_10(payment.gateway_provider_id)

          result = request 'ESPP_0104010', xml.target!

          if !result['ESPP_1204010'].blank?
            return retval(0, result['ESPP_1204010']['f_05'])
          else
            return retval(result['ESPP_2204010']['f_01'])
          end
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        return retval(-1001) if settings_miss?

        begin
          xml = Builder::XmlMarkup.new

          signature = [
            payment.account,
            payment.enrolled_amount,
            810,
            1,
            payment.id,
            payment.created_at,
            @config.setting_agent,
            payment.terminal_id,
            1,
            payment.created_at,
            payment.gateway_provider_id
          ].join('&')

          signature = Digest::MD5.hexdigest(signature)
          encryptor = OpenSSL::PKey::RSA.new(
            File.open(@config.attachment_signature_key.path).read,
            @config.setting_signature_key_password
          )
          signature = encryptor.sign(OpenSSL::Digest::SHA1.new, signature)
          signature = Base64.encode64(signature)

          xml.f_01(payment.account, :"xsi:type" => 'espp-constraints:PHN_CODE_fmt_01')
          xml.f_02(payment.enrolled_amount)
          xml.f_03(810, :"xsi:type" => 'espp-constraints:CUR_fmt_01')
          xml.f_04(1)
          xml.f_06(payment.id)
          xml.f_07(payment.id)
          xml.f_08(payment.created_at.strftime("%Y-%m-%dT%H:%M:%S"))
          xml.f_10(payment.gateway_payment_id)
          xml.f_11(@config.setting_agent)
          xml.f_12(terminal(payment))
          xml.f_13(1)
          xml.f_16(payment.created_at)
          xml.f_18(signature)
          xml.f_19(@config.setting_contract)
          xml.f_21(payment.gateway_provider_id)

          result = request 'ESPP_0104090', xml

          if !result['ESPP_1204090'].blank?
            return retval
          else
            return retval(result['ESPP_2204090']['f_01'])
          end
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def generate_revision(revision)
        xml = Builder::XmlMarkup.new

        xml.summary do
          xml.contract @config.setting_contract
          xml.comparePeriod do
            xml.from revision.date.to_date.to_datetime
            xml.to DateTime.new(
              revision.date.year,
              revision.date.month,
              revision.date.day,
              23,
              59,
              59
            )
          end
          xml.totalAmountOfPayments revision.payments.count
          xml.currency(810, :"xsi:type" => 'espp-constraints:CUR_fmt_01')
          xml.totalSum revision.payments.map{|x| x.enrolled_amount}.inject(:+)
          xml.totalDebt 0
        end
        xml.payments do
          revision.payments.each_with_index do |p,i|
            row = [
              @config.setting_agent,
              p.gateway_payment_id,
              p.created_at,
              p.id,
              p.terminal_id,
              p.account,
              '',
              '',
              p.enrolled_amount,
              810,
              1,
              0
            ].join(';')

            xml.p(row, :id => i+1)
          end
        end

        [:xml, wrap_xml('comparePacket', xml, revision.id)]
      end

    private

      def terminal(payment)
        "#{@config.setting_terminal_prefix[0..10].rjust(11, '0')}.#{payment.terminal_id}"
      end

      def settings_miss?
        @config.setting_terminal_prefix.blank?    ||
        @config.attachment_cert.blank?            ||
        @config.attachment_key.blank?             ||
        @config.attachment_signature_key.blank?   ||
        @config.setting_url.blank?                ||
        @config.setting_agent.blank?              ||
        @config.setting_contract.blank?
      end

      def retval(code=0, payment_id=false)
        result = {:success => (code.to_s == "0"), :error => code}
        result[:gateway_payment_id] = payment_id unless payment_id.blank?

        result
      end

      def wrap_xml(operation, xml, operation_id='')
        operation_id = "id='#{operation_id}'" unless operation_id.blank?

        return <<-XML
<?xml version= "1.0" encoding="UTF-8"?>
<#{operation}
  #{operation_id}
  xmlns="http://schema.mts.ru/ESPP/AgentPayments/Protocol/Messages/v5_01"
  xmlns:espp-constraints="http://schema.mts.ru/ESPP/Core/Constraints/v5_01"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://schema.mts.ru/ESPP/AgentPayments/Protocol/Messages/v5_01 ESPP_AgentPayments_Protocol_Messages_v5_01.xsd" #{"a_01 = \"60\"" if operation == "ESPP_0104010"}>
  #{xml}
</#{operation}>
        XML
      end

      def request(operation, xml)
        result = post @config.setting_url, wrap_xml(operation, xml),
          ssl(
            @config.attachment_cert,
            @config.attachment_key,
            @config.setting_key_password,
            @config.attachment_ca
          )

        logger.debug(dump_xml result) unless logger.blank?
        return Crack::XML.parse(result)
      end

    end
  end
end
