# coding: utf-8

module Payzilla
  module Gateways
    class Mailru < Gateway
      register_settings %w(key)

      def check(payment)
        begin 
          result = send 'user/check', 
              :rcpt => payment.account

          if result == 'OK'
            return {:success => true, :error => "0"}
          else
            result = result.split(':')[0].gsub('E', '').to_i
            return {:success => false, :error => result}
          end
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        begin
          result = send 'payment/make',
            :rcpt        => payment.account,
            :currency    => 'RUR',
            :sum         => payment.enrolled_amount,
            :description => Base64.encode64("Пополнение кошелька")

          if result[0] == 'E'
            result = result.split(':')[0].gsub('E', '').to_i
            return {:success => false, :error => result}
          else
            return {:success => true, :gateway_payment_id => result}
          end
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

    private

      def send(operation, params)
        params[:key] = @config.setting_key

        resource = RestClient::Resource.new("https://merchant.money.mail.ru/api/#{operation}")
        result   = resource.get :params => params

        return result.to_s
      end

    end
  end
end