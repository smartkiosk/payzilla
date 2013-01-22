# coding: utf-8

require 'builder'

module Payzilla
  module Gateways
    class Gorod < Gateway
      include Payzilla::Transports::HTTP

      register_settings %w(domain key_password)
      register_attachments %w(cert key)

      def check(payment)
        return retval(-1001) if settings_miss?

        begin
          xml = Builder::XmlMarkup.new and xml.instruct!

          xml.Document do
            xml.BILLING do
              xml.ReqAbonentList do
                xml.AbonentsOn do
                  xml.AbonentId payment.account
                end
              end
            end
          end

          result = request xml.target!
          return retval(result['fault']['faultactor'])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        return retval(-1001) if settings_miss?

        begin
          xml = Builder::XmlMarkup.new and xml.instruct!

          xml.Document do
            xml.GIN2 do
              xml.FORM do
                xml.Service payment.service
                xml.Abonent do
                  xml.id payment.account
                end
              end
            end
          end

          result = request xml.target!
          return retval(result['fault']['faultactor'])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      private

        def retval(code)
          {:success => (code == "0"), :error => code}
        end

        def request(xml)
          result = post @config.setting_domain, xml,
            ssl(
              @config.attachment_cert,
              @config.attachment_key,
              @config.setting_password
            )

            logger.debug(dump_xml result) unless logger.blank?
            return Crack::XML.parse(result)
        end

    end
  end
end
