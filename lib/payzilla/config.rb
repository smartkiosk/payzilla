require 'yaml'

module Payzilla
  class Config

    # @!attribute setting_bank
    #   Bank identifier
    #   Used by:
    #   * Akado
    #
    # @!attribute setting_key_password
    #   Password, that is needed for decrypt encrypted key
    #   Used by:
    #   * Akado
    #   * Cyberplat
    #   * Matrix
    #   * MTS
    #   * Rapida
    #   * Webmoney
    #
    # @!attribute setting_partner_id
    #   Partner identifier
    #   Used by:
    #   * Beeline
    #
    # @!attribute setting_payment_point_id
    #   Accepting payments point identifier
    #   Used by:
    #   * Beeline
    #
    # @!attribute setting_url
    #   Carrier server URL where data will be sent
    #   Used by:
    #   * Beeline
    #   * Matrix
    #   * MTS
    #   * Rapida
    #   * Skylink
    #   * Webmoney
    #   * Yota
    #
    # @!attribute host
    #   Carrier server URL where data will be sent
    #   Used by:
    #   * Cyberplat
    #
    # @!attribute setting_operator
    #   Acceptance point operator identifier
    #   Used by:
    #   * Ceberplat
    #
    # @!attribute setting_point
    #   Acceptance point identifier
    #   Used by:
    #   * Cyberplat
    # @!attribute setting_dealer
    #   Dealer identifier
    #   Used by:
    #   * Cyberplat
    #
    # @!attribute setting_key
    #   Key
    #   Used by:
    #   * Mailru
    #
    # @!attribute setting_dealer_id
    #   Dealer identifier
    #   Used by:
    #   * Matrix
    #
    # @!attribute setting_domain
    #   Carrier server URL where data will be sent
    #   Used by:
    #   * Megafon
    #   * OSMP
    #
    # @!attribute setting_client
    #   Client identifier. To get this, speak with carrier support.
    #   Used by:
    #   * Megafon
    #   * OSMP
    #   * Skylink
    #
    # @!attribute setting_password
    #   Password, that will be sent with payment
    #   Used by:
    #   * Megafon
    #   * OSMP
    #   * Yamoney
    #
    # @!attribute setting_agent
    #   Agent identifier
    #   _Get this info from carrier_
    #   Used by:
    #   * MTS
    #
    # @!attribute setting_contract
    #   Contract identifier
    #   _Get this info from carrier_
    #   Used by:
    #   * MTS
    #
    # @!attribute setting_signature_key_password
    #   Password, that is neede to decrypt encrypted signature key
    #   _Get this info from carrier_
    #   Used by:
    #   * MTS
    #   * Yota
    #
    # @!attribute setting_terminal_prefix
    #   Some prefix, that would be added to your current kiosk name
    #   Used by:
    #   * MTS
    #
    # @!attribute setting_terminal
    #   Terminal identifier
    #   Used by:
    #   * OSMP
    #
    # @!attribute setting_wmid
    #   WebMoney identifier
    #   Used by:
    #   * Webmoney
    #
    # @!attribute setting_kiosk_id
    #   Kiosk identifier
    #   Used by:
    #   * Webmoney
    #
    # @!attribute setting_currency
    #   Carrier's currency code
    #   Used by:
    #   * Yamoney
    #
    # @!attribute setting_gpg_key
    #   GPG key
    #   Used by:
    #   * Yamoney
    attr_accessor :setting_url, :setting_bank, :setting_key_password,
                  :setting_partner_id, :setting_payment_poind_id,
                  :setting_host, :setting_operator, :setting_poing,
                  :setting_dealer, :setting_key, :setting_dealer_id,
                  :setting_domain, :setting_client, :setting_password,
                  :setting_agent, :setting_contract, :setting_signature_key_password,
                  :setting_terminal_prefix, :setting_terminal, :setting_wmid,
                  :setting_kiosk_id, :setting_currency, :setting_gpg_key

    # @!attribute attachment_cert
    #   File, that contains X509 certificate
    #   Used by:
    #   * Akado
    #   * Beeline
    #   * Matrix
    #   * Megafon
    #   * Rapida
    #   * Webmoney
    #   * Yota
    #
    # @!attribute attachment_wsdl
    #   WSDL file
    #   Used by:
    #   * Beeline
    #
    # @!attribute attachment_private_key
    #   Private key file
    #   Used by:
    #   * Cyberplat
    #   * Rapida
    #
    # @!attribute attachment_public_key
    #   Public key file
    #   Used by:
    #   * Cyberplat
    #   * Yamoney
    #
    # @!attribute attachment_key
    #   File with keypair
    #   Used by:
    #   * Matrix
    #   * Megafon
    #   * Webmoney
    #   * Yota
    #
    # @!attribute attachment_ca
    #   Certificate autority file
    #   * Matrix
    #   * Yota
    #
    # @!attribute attachment_signature_key
    #   File with keypair, that is needed to generate signature
    #   Used by:
    #   * MTS
    #
    # @!attribute attachment_secret_key
    #   Secret key file
    #   Used by:
    #   * Yamoney
    attr_accessor :attachment_cert, :attachment_key, :attachment_ca,
                  :attachment_wsdl, :attachment_private_key,
                  :attachment_public_key, :attachment_signature_key,
                  :attachment_secret_key

    # @!attribute switch_test_mode
    #   Switch to the testing mode
    #   Used by:
    #   * Webmoney
    attr_accessor :switch_test_mode

    def initialize(carrier, config={})
      config = if config.kind_of?(Hash)
                 {carrier => config}
               else
                 ::YAML.load_file(config)
               end

      begin
        config[carrier].each{|k,v| send "#{k}=", v}
      rescue NoMethodError => e
        puts "No such carrier in yaml config file"
        puts e
      end
    end
  end
end
