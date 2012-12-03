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
            :paymentRequest => {
              :partnerId      => @config.setting_partner_id,
              :paymentPointId => @config.setting_payment_point_id,
              :money => {
                :amount => payment.enrolled_amount,
                :code   => 'RUR'
              },
              :amountAll => {
                :amount => payment.paid_amount,
                :code => 'RUR'
              },
              :phone       => payment.account,
              :paymentTime => payment.created_at,
              :externalId  => payment.id
            }

          return retval(result.to_hash[:paymentResponse][:error][:error])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def pay(payment)
        return retval(-1001) if settings_miss?

        begin
          result = request :immediatePayment,
            :paymentRequest => {
              :partnerId      => @config.setting_partner_id,
              :paymentPointId => @config.setting_payment_point_id,
              :money => {
                :amount => payment.enrolled_amount,
                :code   => 'RUR'
              },
              :amountAll => {
                :amount => payment.paid_amount,
                :code => 'RUR'
              },
              :phone       => payment.account,
              :paymentTime => payment.created_at,
              :externalId  => payment.id
            }

          return retval(result.to_hash[:paymentResponse][:error][:error])
        rescue Errno::ECONNRESET
          return retval(-1000)
        end
      end

      def generate_revision(revision)
        return retval(-1001) if settings_miss?

        list = []
        revision.payments.each do |p|
          list << {
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
        end

        data = {
          :reconciliationRequest => {
            :partnerId => @config.setting_partner_id,
            :paymentsList => list,
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

        [:json, ::JSON.generate(data)]    
      end

      def send_revision(revision, data)
        return retval(-1001) if settings_miss?

        begin
          result = request :registerTransfer, JSON.parse(data)
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
        "123"
      end

      def request(method, params)
        client = Savon.client @config.attachment_wsdl.path
        client.wsdl.endpoint = @config.setting_url

        client.request(method) do
          config.logger = logger

          http.auth.ssl.verify_mode = :none

          soap.body   = params
          soap.header = {
            :digitalSignature => {
              :signature => sign_request(soap.send :body_to_xml)
            }
          }
        end
      end
    end
  end
end