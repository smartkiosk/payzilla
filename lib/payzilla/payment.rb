module Payzilla
  class Payment
    def initialize(args={})
      args.each{|k,v| send "#{k}=", v}
    end

    # Dynamic attr_accessor
    def method_missing(k, *v)
      k = k.to_s
      setter = if k[-1] == "="
                 k.slice! -1
               else
                 nil
               end

      unless setter.nil?
        instance_variable_set("@#{k}".to_sym, v.first)
      end

      var = instance_variable_get("@#{k}".to_sym)
      var.nil? ? super : var
    end
  end
end
