module Payzilla
  class Payment

    # @!attribute id
    #   Paymen identifier
    #
    #   Used by:
    #   * Akado
    #   * Beeline
    #   * Cyberplat
    #   * Mailru
    #   * Matrix
    #   * Megafon
    #   * MTS
    #   * OSMP
    #   * Rapida
    #   * Skylink
    #   * Webmoney
    #   * Yamoney
    #   * Yota
    #   @note Should be unique for each paymet (For example current time plus some salt)
    #
    # @!attribute account
    #   Account, which you need to replenish
    #
    #   Used by:
    #   * Akado
    #   * Beeline
    #   * Cyberplat
    #   * Matrix
    #   * Megafon
    #   * MTS
    #   * OSMP
    #   * Skylink
    #   * Yamoney
    #   * Yota
    #
    # @!attribute created_at
    #   Paymend creatiton date
    #
    #   Used by:
    #   * Akado. Format: YYYY-MM-DD HH24:MI:SS by Moscow local time
    #   * Beeline
    #   * Matrix. Format: YYYY-MM-DD HH24:MI:SS by Moscow local time
    #   * Megafon
    #   * MTS
    #   * Skylink
    #   * Yota. Format: YYYY-MM-DDTHH24:MI:SS by  Moscow local time
    #   @note If in this list format is missing, than you can use default DateTime.now without any formating
    #
    # @!attribute enrolled_amount
    #   Amount of money, that client will recieve
    #
    #   Used by:
    #   * Akado. Format: 100.00
    #   * Beeline
    #   * Cyberplat
    #   * Mailru
    #   * Matrix
    #   * Megafon
    #   * MTS. Format: 100.00
    #   * OSMP
    #   * Rapida
    #   * Skylink
    #   * Webmoney
    #   * Yamoney
    #   @note Missing format in this list mens, that you should use integer value without coins
    #
    # @!attribute paid_amount
    #   Amount of money, that client put into kiosk
    #
    #   Used by:
    #   * Beeline
    #   * OSMP
    #   * Skylink
    #
    # @!attribute discount_card
    #   Client's discount card
    #
    #   Used by:
    #   * Beeline _optional_
    #
    # @!attribute subagent_id
    #   Subagent identifier
    #
    #   Used by:
    #   * Beeline. _optional_
    #
    # @!attribute fields
    #   Additional params, that can be passed into payment
    #
    #   Used by:
    #   * Cyberplat
    #   * Rapida
    #   * Webmoney
    #     * phone - account, you need to pay to
    #     * purse - currency
    #     * name  - your name
    #     * passport_serie
    #     * passport_date
    #
    # @!attribute agent_id
    #   Agent identifier
    #
    #   Used by:
    #   * Cyberplat
    #
    # @!attribute terminal_id
    #   Terminal identifier
    #
    #   Used by:
    #   * Cyberplat
    #   * MTS
    #   * Rapida
    #
    # @!attribute gateway_payment_id
    #   Gateway payment idetifier. You can get it by parsing response of check method
    #
    #   Used by:
    #   * Matrix
    #   * MTS
    #
    # @!attribute gateway_provider_id
    #   Gateway provider identifier
    #
    #   Used by:
    #   * MTS
    #   * OSMP
    #   * Rapida
    #
    # @!attribute commision_amount
    #   Amount of commision, that would be subtracted from enrolled amount
    #
    #   Used by:
    #   * Rapida
    #
    # @!attribute payment_type
    #   Chose payment type. On the left side is 'what you want', and on the right - what you should pass
    #   * Cash         | self::TYPE_CASH
    #   * Inner card   | self::TYPE_INNER_CARD
    #   * Foreign card | self::TYPE_FOREIGN_CARD
    #   * Bank account | self::TYPE_IBANK
    #   * Account      | self::TYPE_ACCOUNT
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
