require 'stringio'

module Payzilla
  module Utils
    class StringFile < StringIO
      attr_accessor :path

      def initialize(filename, content)
        self.path = filename
        super content
      end
    end
  end
end