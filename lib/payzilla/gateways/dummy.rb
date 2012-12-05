require 'builder'

module Payzilla
  module Gateways
    class Dummy < Gateway
      requires_revision
      register_switches %w(allow_fails)

      def check(payment)
        retval
      end

      def pay(payment)
        retval
      end

      def generate_revision(revision)
        buffer = []

        paginate_payments(revision.payments, buffer) do |slice, buffer|
          buffer << generate_revision_page(slice)
        end

        [:xml, buffer.join('')]
      end

      def send_revision(revision, data)
        retval
      end

    private

      def generate_revision_page(payments)
        payments.to_xml(:skip_instruct => true, :root => 'slice')
      end

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