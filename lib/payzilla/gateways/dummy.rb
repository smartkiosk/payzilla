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
        [:xml, revision.payments.to_xml]
      end

      def send_revision(revision, data)
        retval
      end

    private

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