module Payzilla
  class Payment
    def initialize(args={})
      args.each{|k,v| send "#{k}=", v}
    end
  end
end