module Payzilla
  class Payment
    attr_accessor :id, :account, :created_at, :enrolled_amount,
                  :paid_amount, :terminal_id, :gateway_provider_id,
                  :discount_card, :subagent_id, :agent_id, :fields,
                  :commission_amount

    def initialize(args={})
      args.each{|k,v| send "#{k}=", v}
    end
  end
end
