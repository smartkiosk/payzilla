# coding: utf-8

require 'gpgme'

module Payzilla
  module Gateways
    class Yamoney < Gateway
      register_settings    %w(url currency password)

      def check(payment)
        begin
          result = send '1002',
            :TR_NR      => payment.id,
            :DSTACNT_NR => payment.account,
            :TR_AMT     => payment.enrolled_amount,
            :CUR_CD     => @config.setting_currency,
            :SIGN       => sign([payment.id, 1002, payment.account, payment.enrolled_amount, @config.setting_currency])

          return retval(result)
        rescue Errno::ECONNRESET
          return {:success => false, :error => -1000}
        end
      end

      def pay(payment)
        begin
          result = send '1',
            :TR_NR      => payment.id,
            :DSTACNT_NR => payment.account,
            :TR_AMT     => payment.enrolled_amount,
            :CUR_CD     => @config.setting_currency,
            :CONT       => "Пополнение кошелька".encode("Windows-1251"),
            :SIGN       => sign([payment.id, 1002, payment.account, payment.enrolled_amount, @config.setting_currency])

          return retval(result)
        rescue Errno::ECONNRESET
          return {:success => false, :error => -1000}
        end
      end

    private

      def retval(result)
        if result[:RES_CD] == "0"
          return {:success => true, :error => "0"}
        else
          return {:success => false, :error => result[:ERR_CD]}
        end
      end

      def sign(values)
        crypto = GPGME::Crypto.new
        signature = crypto.clearsign values.map{|x| x.to_s}.join('&')
        signature.read
      end

      def send(operation, params)
        params[:ACT_CD] = operation
        params[:VERSION] = '2.02'

        resource = RestClient::Resource.new(@config.setting_url)

        result = resource.post :params => params
        result = GPGME::Crypto.new.decrypt(result.to_s,
                                           :password => @config.setting_password)
        result = result.split("\n").map{|x| x.split("=")}.flatten
        result = Hash[*result].with_indifferent_access

        return result
      end

    end
  end
end
