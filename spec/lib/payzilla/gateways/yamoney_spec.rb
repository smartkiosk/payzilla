require 'spec_helper'

describe Payzilla::Gateways::Yamoney do
  before(:all) do
    config = ConfigStub.new('yamoney')

    config.setting_url      = "https://money.yandex.ru/api/"
    config.setting_currency = 10643
    config.setting_password = "round345"

    config.attachment_gpg   = File.new("certificates/yandex.gpg")

    @transport = Payzilla::Gateways::Yamoney.new(config, './log/yamoney.log')

    @payment = OpenStruct.new(
      :id              => 123,
      :account         => 4100175017397,
      :enrolled_amount => 100.25
    )
  end

  it "checks" do
    @transport.check(@payment)[:success].should == true
  end

  xit "pays" do
    @transport.pay(@payment)[:success].should == true
  end
end
