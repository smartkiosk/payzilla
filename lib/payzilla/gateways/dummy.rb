require 'builder'

module Payzilla
  module Gateways
    class Dummy < Gateway
      requires_revision
      register_switches %w(allow_fails)

      # Validate payment on server's side
      #
      # @param [Payment] payment
      # @return [Hash] hash with error code
      def check(payment)
        retval
      end

      # Send payment to the carrier's server
      #
      # @param [Payment] payment
      # @return [Hash] hash with error code
      def pay(payment)
        retval
      end

      # Generate revision
      #
      # @param [Revision] revision
      # @return [Array] array with ready-to-send revision
      def generate_revision(revision)
        buffer = []

        paginate_payments(revision.payments, buffer) do |slice, buffer|
          buffer << generate_revision_page(slice)
        end

        [:xml, buffer.join('')]
      end

      # Send revision to the carrier's server
      #
      # @param [Revision] revision
      # @param [Array] data is generated from `generate_revision` method
      # @return [Hash] hash with error code
      def send_revision(revision, data)
        retval
      end

    private

      # Generate revision page for revision payments pagination
      # @param [Array] payments array of instances of Payzilla::Payment
      # @return [String] with XML-formatted payments
      def generate_revision_page(payments)
        payments.to_xml(:skip_instruct => true, :root => 'slice')
      end

      # Return user-friendly error code
      #
      # @return [Hash] hash with error code
      def retval
        if @config.switch_allow_fails
          [
            {:success => true, :error => 0},
            {:success => false, :error => -1}
          ].sample
        else
          {:success => true, :error => 0}
        end
      end
    end
  end
end
