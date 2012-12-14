require 'spec_helper'

describe Payzilla::Gateways::Matrix do
  before(:all) do
    config = ConfigStub.new('matrix')

    config.setting_dealer_id    = 123
    config.setting_key_password = "qwer"

    config.attachment_cert = File.new("certificates/matrix.cer")
    config.attachment_key  = File.new("certificates/matrix.key")
    config.attachment_ca   = File.new("certificates/matrix.key")

    @transport = Payzilla::Gateways::Matrix.new(config, './log/matrix.log')

    @payment = OpenStruct.new(
      :account            => 946848764,
      :enrolled_amount    => 100,
      :created_at         => DateTime.now.strftime("%Y-%m-%d %H:%M:%S"),
      :gateway_payment_id => 23456,
      :id                 => 4356123
    )
  end

  it "checks" do
    @transport.check(@payment)[:success].should == true
  end

  it "pays" do
    @transport.pay(@payment)[:success].should == true
  end
end