# coding: utf-8

module Payzilla
  module Gateways
    class Akado < Gateway
      register_settings %w(bank key_password)
      register_attachments %w(cert key ca)

      def check(payment)
        begin 
          result = send 'check_pay', 
            :numabo => payment.account

          return retval(result)
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        begin
          result = send 'pay',
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

      def send(operation, params)
        params[:type] = operation

        resource = RestClient::Resource.new(
          "https://payment.comcor–tv.ru/#{@config.setting_bank}/payorder.php",
          ssl_settings(
            @config.attachment_cert,
            @config.attachment_key,
            @config.setting_key_password,
            @config.attachment_ca
          )
        )

        result = resource.get :params => params
        return result.to_s
      end

    end
  end
end