# coding: utf-8

require 'builder'
require 'crack'

module Payzilla
  module Gateways
    class Skylink < Gateway
      requires_revision
      register_settings %w(client url)

      def check(payment)
        begin 
          result = send 'VALIDATE_PHONE',
            :PhoneNum => payment.account

          return retval(result['string'].split(':').first)
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        begin
          transaction = get_transaction

          result = send 'PAY_CASH_INPUT',
            :PayNum => transaction,
            :PurposeID => 2,
            :PurposeNum => payment.account,
            :PaySum => payment.enrolled_amount,
            :PayDate => payment.created_at.strftime("%d.%m.%Y %H:%M:%S"),
            :RegDate => payment.created_at.strftime("%d.%m.%Y %H:%M:%S"),
            :Payer => 'Tester',
            :CardNum => '',
            :PosNum => "0",
            :PayDocNum => payment.id,
            :Dsc => '1'


          return retval(result, transaction)
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def revise(payments, date)
        builder = Builder::XmlMarkup.new

        builder.instruct!
        data = builder.payments do
          paginate_payments(payments, builder) do |slice, builder|
            generate_revision_page(slice, builder)
          end
        end

        result = send 'REPORT_XML_SEND',
          :RegDate => date.strftime("%d.%m.%Y"),
          :Register => data

        return retval(result)
      end

    private

      def generate_revision_page(payments, builder)
        payments.each do |p|
          builder.payment(
            :PaySum => p.enrolled_amount,
            :PayType => 1,
            :PurposeID => 2,
            :PurposeNum => p.account,
            :PayNum => p.gateway_payment_id,
            :PayDate => p.created_at.strftime("%d.%m.%Y %H:%M:%S"),
            :RegDate => p.created_at.strftime("%d.%m.%Y %H:%M:%S"),
            :PosNum => "0",
            :PayDocNum => p.id
          )
        end
      end

      def retval(code, transaction=false)
        result = {:success => (code == "0"), :error => code}
        result[:gateway_payment_id] = transaction if transaction

        result
      end

      def get_transaction
        return send('PAY_NUM_GET')["int"].to_i
      end

      def send(operation, params={})
        if @config.setting_client.blank?   ||
           @config.setting_url.blank?
           return -1001
         end

        params[:PaySystemCode] = @config.setting_client
        
        result = RestClient.post "#{@config.setting_url}/#{operation}", params
        return Crack::XML.parse(result)
      end
    end
  end
end
