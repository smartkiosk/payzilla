require 'rexml/document'

module Payzilla
  module Gateways
    class Gateway
      attr_accessor :config
      attr_accessor :logger
      attr_accessor :revision_page_size

      def initialize(config, log=nil)
        @config = config

        if defined?(Rails) && Rails.root.join('log/gateways').directory?
          log ||= Rails.root.join("log/gateways/#{@config.keyword}.log")
        end

        if !log.respond_to?(:info)
          @logger = Logger.new log.to_s, 2
          @logger.level = Logger::DEBUG
          @logger.level = @config.debug_level if @config.respond_to?(:debug_level)
          @logger.formatter = Logger::Formatter.new
        end

        @revision_page_size = 5000
      end

      def self.register_settings(list)
        @available_settings = list
      end

      def self.register_attachments(list)
        @available_attachments = list
      end

      def self.register_switches(list)
        @available_switches = list
      end

      def self.require_payment_fields(list)
        @required_payment_fields = list
      end

      def self.required_payment_fields
        @required_payment_fields || []
      end

      def self.available_settings
        @available_settings || []
      end

      def self.available_attachments
        @available_attachments || []
      end

      def self.available_switches
        @available_switches || []
      end

      def requires_revision?
        self.class.requires_revision?
      end

      def self.requires_revision?
        @requires_revision == true
      end

      def self.requires_revision
        @requires_revision = true
      end

      def can_list_providers?
        self.class.can_list_providers?
      end

      def self.can_list_providers?
        @can_list_providers == true
      end

      def self.can_list_providers
        @can_list_providers = true
      end

      def revise(revision)
        send_revision revision, generate_revision(revision)[1]
      end

    protected

      def paginate_payments(payments, *args, &block)
        totals = {
          :count        => 0,
          :enrolled_sum => 0,
          :paid_sum     => 0
        }

        if payments.respond_to?(:limit)
          pages = (payments.count.to_f / revision_page_size.to_f).ceil

          pages.times do |p|
            slice = payments.offset(p*revision_page_size).limit(revision_page_size)

            yield slice, *args

            totals[:count]        += slice.count
            totals[:enrolled_sum] += slice.map{|x| x.enrolled_amount}.inject(:+)
            totals[:paid_sum]     += slice.map{|x| x.paid_amount}.inject(:+)
          end
        else
          yield payments, *args

          totals[:count]        = payments.count
          totals[:enrolled_sum] = payments.map{|x| x.enrolled_amount}.inject(:+)
          totals[:paid_sum]     = payments.map{|x| x.paid_amount}.inject(:+)
        end

        totals
      end

      def dump_xml(text)
        xml = ""
        doc = REXML::Document.new(text)
        doc.write(xml, 1)
        xml = "XML DUMP\n#{'-'*30}\n#{xml}\n#{'-'*30}"
        xml
      end
    end
  end
end