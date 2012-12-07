# coding: utf-8

require 'builder'

module Payzilla
  module Gateways
    class Skylink < Gateway
      requires_revision
      register_settings %w(client url)

      def check(payment)
        begin 
          result = send 'Validate_phone',
            :PhoneNum => payment.account

          return retval(result)
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        begin
          transaction = get_transaction

          result = send 'Pay_cash_input',
            :PayNum => transaction,
            :PurposeID => 2,
            :PurposeNum => payment.account,
            :PaySum => payment.enrolled_amount,
            :PayDate => payment.created_at.strftime("%d.%m.%Y %H:%M:%S"),
            :RegDate => payment.created_at.strftime("%d.%m.%Y %H:%M:%S"),
            :PosNum => "0",
            :PayDocNum => payment.id

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

        result = send 'Report_xml_send',
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
            :PayDate => payment.created_at.strftime("%d.%m.%Y %H:%M:%S"),
            :RegDate => payment.created_at.strftime("%d.%m.%Y %H:%M:%S"),
            :PosNum => "0",
            :PayDocNum => payment.id
          )
        end
      end

      def retval(code, transaction=false)
        result = {:success => (code == "0"), :error => code}
        result[:gateway_payment_id] = transaction if transaction

        result
      end

      def get_transaction
        return send('Pay_num_get')
      end

      def send(operation, params={})
        if @config.setting_client.blank?   ||
           @config.setting_url.blank?
           return -1001
         end

        params[:PaySystemCode] = @config.setting_client

        builder = Builder::XmlMarkup.new
        builder.instruct!
        data = builder.tag!(operation) do
          params.each do |k, v|
            builder.tag!(k, v)
          end
        end

        resource = RestClient::Resource.new(@config.setting_url)
        result   = resource.post data.to_s
        return result.to_s
      end
    end
  end
end
