require 'savon'
require 'json'
require 'gyoku'

module Payzilla
  module Gateways
    class Beeline < Gateway
      requires_revision
      register_settings %w(url partner_id payment_point_id)
      register_attachments %w(wsdl cert key ca)

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

        list_json = list_xml = []
        revision.payments.each do |p|
          list_json << {
            :paymentPointId => @config.setting_payment_point_id,
            :money => {
              :amount => p.enrolled_amount,
              :code   => 'RUR'
            },
            :amountAll => {
              :amount => p.paid_amount,
              :code => 'RUR'
            },
            :phone       => p.account,
            :paymentTime => p.created_at,
            :externalId  => p.id
          }

          list_xml << {
            :reconciliationPayment => {
              :paymentPointId => @config.setting_payment_point_id,
              :money       => "",
              :phone       => p.account,
              :subagentId  => p.subagent_id,

              :attributes! => {
                :money => {
                  :amount => p.enrolled_amount,
                  :code   => 'RUR'
                }
              }
            },

            :attributes! => {
              :reconciliationPayment => {
                :paymentTime  => p.created_at,
                :externalId   => p.id,
                :registeredId => p.id
              }
            }
          }
        end

        data_json = {
          :reconciliationRequest => {
            :partnerId => @config.setting_partner_id,
            :paymentsList => list_json,
            :startTime => revision.date.to_date.to_datetime,
            :endTime => DateTime.new(
                          revision.date.year,
                          revision.date.month,
                          revision.date.day,
                          23,
                          59,
                          59
                        )
          }
        }

        data_xml = {
          :partnerId => @config.setting_partner_id,
          :paymentsList => list_xml,

          :attributes! => {
            :partnerId => { :xmlns => "http://payment.beepayxp.jetinfosoft.ru/PaymentTypes.xsd" }
          }
        }

        [:json, ::JSON.generate(data_json), :xml, data_xml]
      end

      def send_revision(revision, opts)
        return retval(-1001) if settings_miss?
        opts.merge!({:method => "reconciliation"})

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
        @config.attachment_cert.blank?          ||
        @config.attachment_key.blank?           ||
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

      def request(method, params, opts={})
        Savon.config.env_namespace = :soap
        client = Savon.client @config.attachment_wsdl.path
        client.wsdl.endpoint = @config.setting_url

        client.request(method) do
          config.logger = logger

          http.auth.ssl.verify_mode = :none
          soap.element_form_default = :unqualified
          soap.namespaces.delete("xmlns:pt")
          soap.input = ["#{opts[:method]}Request"]
          soap.input << if method == :register_transfer
                          {
                            :startTime => opts[:start_time],
                            :endTime   => opts[:end_time]
                          }
                        else
                          {
                            :paymentTime => payment.created_at.strftime("%Y-%m-%dT%H:%M:%SZ%:z"),
                            :externalId  => payment.id,
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
