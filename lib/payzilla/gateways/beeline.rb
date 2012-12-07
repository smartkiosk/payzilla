require 'savon'
require 'json'
require 'gyoku'

module Payzilla
  module Gateways
    class Beeline < Gateway
      requires_revision
      register_settings %w(url partner_id payment_point_id)
      register_attachments %w(wsdl ca)

      def check(payment)
        begin
          result = request :create_payment,
            {
              :partnerId      => @config.setting_partner_id,
              :paymentPointId => @config.setting_payment_point_id,
              :money => "",
              :phone       => payment.account,
              :amountAll => "",
              :attributes! => {
                :money => {
                  :amount => payment.enrolled_amount,
                  :code   => 'RUR'
                },
                :amountAll => {
                  :amount => payment.paid_amount,
                  :code => 'RUR'
                }
              }
            }, payment

          return retval(result.to_hash[:paymentResponse][:error][:error])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        return retval(-1001) if settings_miss?

        begin
          result = request :immediate_payment,
            {
              :partnerId      => @config.setting_partner_id,
              :subagentId     => payment.subagent_id,
              :paymentPointId => @config.setting_payment_point_id,
              :money => "",
              :phone       => payment.account,
              :discountCardNumber => payment.discount_card,

              :attributes! => {
                :money => {
                  :amount => payment.enrolled_amount,
                  :code   => 'RUR'
                }
              }
            }, payment

          return retval(result.to_hash[:paymentResponse][:error][:error])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def generate_revision(revision)
        return retval(-1001) if settings_miss?

        builder = []
        paginate_payments(revision.payments, builder) do |slice,buidler|
          generate_revision_page(slice, builder)
        end
        data = {
          :partnerId => @config.setting_partner_id,
          :paymentsList => builder,

          :attributes! => {
            :partnerId => { :xmlns => "http://payment.beepayxp.jetinfosoft.ru/PaymentTypes.xsd" },
            :paymentsList => { :xmlns => "http://payment.beepayxp.jetinfosoft.ru/PaymentTypes.xsd" }
          }
        }
        [:xml, data]
      end

      def generate_revision_page(payments, builder)
        payments.each do |p|
          builder << {
            :reconciliationPayment => {
              :subagentId  => p.subagent_id,
              :paymentPointId => @config.setting_payment_point_id,
              :money       => "",
              :phone       => p.account,

              :attributes! => {
                :money => {
                  :amount => p.enrolled_amount,
                  :code   => 'RUR'
                }
              }
            },

            :attributes! => {
              :reconciliationPayment => {
                :paymentTime  => p.created_at.strftime("%Y-%m-%dT%H:%M:%SZ%:z"),
                :externalId   => p.id,
                :registeredId => p.id
              }
            }
          }
        end
      end

      def send_revision(revision)
        return retval(-1001) if settings_miss?
        opts = {
          :method => "reconciliation",
          :startTime => revision.date.to_date.to_datetime.strftime("%Y-%m-%dT%H:%M:%SZ%:z"),
          :endTime => DateTime.new(
                        revision.date.year,
                        revision.date.month,
                        revision.date.day,
                        23,
                        59,
                        59
                      ).strftime("%Y-%m-%dT%H:%M:%SZ%:z")
        }
        revision = generate_revision(revision)[1]

        begin
          result = request :register_transfer, revision, opts
          return retval(result.to_hash[:reconciliationResponse][:error][:error])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

    private

      def settings_miss?
        @config.setting_partner_id.blank?       ||
        @config.setting_payment_point_id.blank? ||
        @config.attachment_wsdl.blank?
      end

      def retval(code)
        {:success => (code.to_s == "0"), :error => code}
      end

      def sign_request(text)
        #begin
        #  system("cryptcp -sign -f 22.cer -nochain test.txt test.msg")
        #  File.read("test.txt")
        #ensure
        #  raise "cryptcp failed while doing something" if $? != 0
        #end
        "123"
      end

      def request(method, params, opts)
        Savon.config.env_namespace = :soap
        client = Savon.client @config.attachment_wsdl.path
        client.wsdl.endpoint = @config.setting_url

        client.request(method) do
          config.logger = logger

          http.auth.ssl.verify_mode = :none
          soap.element_form_default = :unqualified
          soap.namespaces.delete("xmlns:pt")
          soap.input = ["#{opts.kind_of?(Hash) ? opts[:method] : method.to_s.lower_camelcase}Request"]
          soap.input << if method == :register_transfer
                          {
                            :startTime => opts[:startTime],
                            :endTime   => opts[:endTime],
                            :xmlns     => "http://payment.beepayxp.jetinfosoft.ru"
                          }
                        else
                          {
                            :paymentTime => opts.created_at.strftime("%Y-%m-%dT%H:%M:%SZ%:z"),
                            :externalId  => opts.id,
                            :xmlns       => "http://payment.beepayxp.jetinfosoft.ru"
                          }
                        end
          soap.body   = params
          soap.header = {
            :digitalSignature => {
              :signature => sign_request(soap.send :body_to_xml)
            },
            :attributes! => {
              :digitalSignature => {:xmlns => "http://payment.beepayxp.jetinfosoft.ru"}
            }
          }
        end
      end
    end
  end
end
