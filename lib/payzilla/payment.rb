module Payzilla
  class Payment
    attr_accessor :id, :account, :created_at, :enrolled_amount,
                  :paid_amount, :terminal_id, :gateway_provider_id,
                  :discount_card, :subagent_id, :agent_id, :fields,
                  :commission_amount, :payment_type

    TYPE_CASH         = 0
    TYPE_INNER_CARD   = 1
    TYPE_FOREIGN_CARD = 2
    TYPE_IBANK        = 3
    TYPE_ACCOUNT      = 4

    def initialize(args={})
      payment_type = self::TYPE_CASH

      args.each{|k,v| send "#{k}=", v}
    end
  end
end
