require 'spec_helper'

describe Payzilla::Gateways::Yota do
  before(:all) do
    config = ConfigStub.new('yota')

    config.setting_url          = "https://yota.ru/pay"
    config.setting_key_password = "qwerty"

    config.attachment_cert = File.new("certificates/yota.cer")
    config.attachment_key  = File.new("certificates/yota.key")
    config.attachment_ca   = File.new("certificates/yota.key")

    @transport = Payzilla::Gateways::Yota.new(config, './log/yota.log')

    @payment = OpenStruct.new(
      :account => 123456789,
      :id      => 123,
      :created_at => DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")
    )
  end

  it "checks" do
    @transport.check(@payment)[:success].should == true
  end

  it "pays" do
    @transport.pay(@payment)[:success].should == true
  end
end
