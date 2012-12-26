# coding: utf-8

require 'gpgme'

module Payzilla
  module Gateways
    class Yamoney < Gateway
      register_settings    %w(url currency password gpg_key)
      register_attachments %w(public_key secret_key)

      def check(payment)
        begin
          result = send :VERSION    => '2.02',
                        :TR_NR      => payment.id,
                        :DSTACNT_NR => payment.account,
                        :TR_AMT     => payment.enrolled_amount,
                        :CUR_CD     => @config.setting_currency,
                        :ACT_CD     => 1002,
                        :SIGN       => sign([payment.id, 1002, payment.account, payment.enrolled_amount, @config.setting_currency])

          return retval(result)
        rescue Errno::ECONNRESET
          return {:success => false, :error => -1000}
        end
      end

      def pay(payment)
        begin
          result = send :VERSION    => '2.02',
                        :TR_NR      => payment.id,
                        :DSTACNT_NR => payment.account,
                        :TR_AMT     => payment.enrolled_amount,
                        :CUR_CD     => @config.setting_currency,
                        :ACT_CD     => 1,
                        :CONT       => "Пополнение кошелька".encode("Windows-1251"),
                        :SIGN       => sign([payment.id, 1002, payment.account, payment.enrolled_amount, @config.setting_currency])

          return retval(result)
        rescue Errno::ECONNRESET
          return {:success => false, :error => -1000}
        end
      end

    private

      def retval(result)
        if result["RES_CD"].strip == "0"
          return {:success => true, :error => "0"}
        else
          return {:success => false, :error => result["ERR_CD"].strip}
        end
      end

      def sign(values)
        attach_keys

        crypto = GPGME::Crypto.new :armor => true
        crypto.clearsign(values.map{|x| x.to_s}.join('&'),
                            {
                              :password => @config.setting_password,
                              :signer   => @config.setting_gpg_key
                            }
                        )
      end

      def attach_keys
        %w(public secret).each do |key|
          if GPGME::Key.find(key.to_sym, @config.setting_gpg_key).empty?
            GPGME::Key.import(File.open(@config.send("attachment_#{key}_key".to_sym)))
          end
        end
      end

      def send(params)
        resource = RestClient::Resource.new(@config.setting_url)

        result = resource.post :params => params
        sign   = GPGME::Crypto.new(:armor => true)
        params = sign.verify(result.to_s) do |sig|
          result = {"RES_CD" => "1", "ERR_CD" => "Bad signature" } if sig.bad?
        end

        return result if result.kind_of?(Hash)
        result = params.to_s.split("\n").map{|x| x.split("=")}.flatten
        result = Hash[*result]

        return result
      end

    end
  end
end
