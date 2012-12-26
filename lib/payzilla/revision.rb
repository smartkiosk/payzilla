module Payzilla
  class Revision

    # @!attribute payments
    #   Array of instances of Payzilla::Payment
    #
    # @!attribute date
    #   Simple date instance, for example Date.today
    #
    # @!attribute id
    #   Some unique revision identifier
    attr_accessor :payments, :date, :id

    def initialize(args={})
      args.each{|k,v| send "#{k}=", v}
    end
  end
end
