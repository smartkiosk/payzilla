require 'spec_helper'

describe Payzilla::Gateways::Yamoney do
  before(:all) do
    config = ConfigStub.new('yamoney')

    config.setting_url      = "https://bo-demo02.yamoney.ru/onlinegates/mkb.aspx"
    config.setting_currency = 10643
    config.setting_password = "round345"
    config.setting_gpg_key  = "MKB"

    config.attachment_public_key  = File.new('certificates/yandex_public.asc')
    config.attachment_secret_key = File.new('certificates/yandex_private.gpg')

    @transport = Payzilla::Gateways::Yamoney.new(config, './log/yamoney.log')

    @payment = OpenStruct.new(
      :id              => Time.now.to_i.to_s,
      :account         => 4100175017397,
      :enrolled_amount => 100.25
    )
  end

  it "checks" do
    @transport.check(@payment)[:success].should == true
  end

  it "pays" do
    @transport.pay(@payment)[:success].should == true
  end
end
