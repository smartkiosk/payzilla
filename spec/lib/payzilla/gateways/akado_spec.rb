require 'spec_helper'

describe Payzilla::Gateways::Akado do
  before(:all) do
    config = ConfigStub.new('akado')

    config.setting_bank = "mkb_test"
    config.setting_key_password = "12345"

    config.attachment_cert = File.new('certificates/akado.pem')
    config.attachment_key  = File.new('certificates/akado.pem')
    config.attachment_ca   = File.new('certificates/akado.pem')

    @transport = Payzilla::Gateways::Akado.new(config, './log/akado.log')

    @payment = OpenStruct.new(
      :account         => "30000051",
      :created_at      => DateTime.now.strftime("%Y-%m-%d %H:%M:%S"),
      :id              => rand(1000),
      :enrolled_amount => 100
    )
  end

  it "checks" do
    @transport.check(@payment)[:success].should == true
  end

  it "pays" do
    @transport.pay(@payment)[:success].should == true
  end
end
