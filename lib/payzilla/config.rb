require 'yaml'

module Payzilla
  class Config
    attr_accessor :setting_url, :setting_bank, :setting_key_password,
                  :setting_partner_id, :setting_payment_poind_id,
                  :setting_host, :setting_operator, :setting_poing,
                  :setting_dealer, :setting_key, :setting_dealer_id,
                  :setting_domain, :setting_client, :setting_password,
                  :setting_agent, :setting_contract, :setting_signature_key_password,
                  :setting_terminal_prefix, :setting_terminal, :setting_wmid,
                  :setting_kiosk_id, :setting_currency, :setting_gpg_key

    attr_accessor :attachment_cert, :attachment_key, :attachment_ca,
                  :attachment_wsdl, :attachment_private_key,
                  :attachment_public_key, :attachment_signature_key,
                  :attachment_secret_key

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
