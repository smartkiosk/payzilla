# coding: utf-8

require 'crack'
require 'builder'

module Payzilla
  module Gateways
    class Megafon < Gateway
      include Payzilla::Transports::HTTP

      requires_revision
      register_settings %w(domain client password key_password)
      register_attachments %w(cert key ca)

      def check(payment)
        result = request 'HTTP_ADD_PAYMENT', :get,
          :P_MSISDN => payment.account

        return retval(result)
      end

      def pay(payment)
        begin
          result = request 'HTTP_ADD_PAYMENT', :get,
            :P_MSISDN      => payment.account,
            :P_PAY_AMOUNT  => payment.enrolled_amount,
            :P_RECEIPT_NUM => payment.id
        ensure
          pay(payment) if result == "100"
        end

        return retval(result)
      end

      def generate_revision(revision)
        builder = Builder::XmlMarkup.new

        builder.instruct! :xml, version: "1.0", encoding: "WINDOWS-1251"
        data = builder.reestr do
          revision.payments.each do |p|
            builder.r do
              builder.m p.account
              builder.s p.enrolled_amount
              builder.n p.id
              builder.d p.created_at.strftime("%d.%m.%Y %H:%M:%S")
            end
          end
          builder.pay_sum revision.payments.map{|x| x.enrolled_amount}.inject(:+)
          builder.pay_count revision.payments.count
        end

        [:xml, data]
      end

      def send_revision(revision, data)
        result = request 'HTTP_LOAD_REESTR', :post,
          :LOGIN     => @config.setting_client,
          :PASSWORD  => @config.setting_password,
          :P_DATE    => revision.date.strftime('%d.%m.%Y'),
          :FILE_DATA => Payzilla::Utils::StringFile.new('data.xml', data)
        return retval(result)
      end

    private

      def retval(code)
        {:success => (code == "0"), :error => code}
      end

      def request(operation, method, params)
        begin
          if @config.setting_client.blank?   ||
             @config.setting_password.blank? ||
             @config.attachment_cert.blank?  ||
             @config.attachment_key.blank?
             return -1001
          end

            params = {
              :P_LOGIN_NAME => @config.setting_client,
              :P_LOGIN_PASSWD => @config.setting_password,
            }.merge(params)

          result = send method, "https://#{@config.setting_domain}/PAYS/#{operation}", params,
            ssl(
              @config.attachment_cert,
              @config.attachment_key,
              @config.attachment_ca
            )

          logger.debug(dump_xml result) unless logger.blank?
          return Crack::XML.parse(result)['KKM_PG_GATE']['ERROR']['SQLCODE']
        rescue Errno::ECONNRESET
          return -1000
        rescue Exception => e
          logger.fatal e unless logger.blank?
          return -1002
        end
      end

    end
  end
end
