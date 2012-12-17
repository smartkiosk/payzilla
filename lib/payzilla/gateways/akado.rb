# coding: utf-8

require 'cgi'

module Payzilla
  module Gateways
    class Akado < Gateway
      include Payzilla::Transports::HTTP
      register_settings %w(key_password bank)
      register_attachments %w(cert key ca)

      def check(payment)
        begin
          result = request 'check_pay',
            :numabo => payment.account

          return retval(result)
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        begin
          result = request 'pay',
            :date   => payment.created_at,
            :id     => payment.id,
            :numabo => payment.account,
            :summ   => payment.enrolled_amount

          return retval(result)
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

    private

      def retval(code)
        {:success => (code == "0"), :error => code}
      end

      def request(operation, params)
        params[:type] = operation

        request = send :get, "https://payment.comcor-tv.ru/#{@config.setting_bank}/payorder.php", params,
          ssl(
            @config.attachment_cert,
            @config.attachment_key,
            @config.setting_key_password,
            @config.attachment_ca
          )

        return CGI.parse(request)["code"].first
      end

    end
  end
end
