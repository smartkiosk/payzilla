module Payzilla
  class Revision
    attr_accessor :payments, :date, :id

    def initialize(args={})
      args.each{|k,v| send "#{k}=", v}
    end
  end
end