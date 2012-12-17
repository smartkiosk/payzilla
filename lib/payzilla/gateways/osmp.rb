# coding: utf-8

require 'nokogiri'
require 'crack'

module Payzilla
  module Gateways
    class Osmp < Gateway
      register_settings %w(client password terminal domain)

      def check(payment)
        builder = Builder::XmlMarkup.new
        builder.instruct!
        data = builder.request do
          builder.tag! "request-type", 32
          builder.tag! "terminal-id", @config.setting_client
          builder.extra @config.setting_password, "name" => "password"
          builder.extra payment.account,          "name" => "phone"
        end

        begin
          result = send data
          result = Crack::XML.parse(result)
          # TODO: Change returning code, when user doesn't exist
          code = if result["response"]["exist"] == "0"
                   "1"
                 else
                   result["response"]["result_code"]
                 end
        rescue Errno::ECONNRESET
          code = -1000
        end

        retval(code)
      end

      def pay(payment)
        builder = Builder::XmlMarkup.new
        builder.instruct!
        data = builder.request do
          builder.tag! "request-type", 10
          builder.extra @config.setting_password, "name" => "password"
          builder.tag! "terminal-id", @config.setting_client
          builder.auth do
            builder.payment do
              builder.tag! "transaction-number", Time.now.to_i
              builder.to do
                builder.amount payment.paid_amount
                builder.tag! "service-id", 99
                builder.tag! "account-number", payment.account
              end
            end
          end
        end
        begin
          result = send data
          code = Nokogiri.XML(result).css("payment").
            first.attributes["status"].value
        rescue Errno::ECONNRESET
          code = -1000
        end

        retval(code, true)
      end

    private

      def retval(code, payment=nil)
        if payment
          {:success => (code == "50"), :error => code}
        else
          {:success => (code == "0"), :error => code}
        end
      end

      def send(data)
        result = RestClient.post @config.setting_domain, data

        logger.debug(result.body) unless logger.blank?
        return result.body
      end

    end
  end
end
