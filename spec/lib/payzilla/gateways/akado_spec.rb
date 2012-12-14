require 'spec_helper'

describe Payzilla::Gateways::Akado do
  before(:all) do
    config = ConfigStub.new('akado')

    config.setting_bank         = "MKB"
    config.setting_key_password = "12345"

    config.attachment_cert = File.new('certificates/akado.cer')
    config.attachment_key  = File.new('certificates/akado.key')
    config.attachment_ca   = File.new('certificates/akado.key')

    @transport = Payzilla::Gateways::Akado.new(config, './log/akado.log')

    @payment = OpenStruct.new(
      :account         => "30000579",
      :created_at      => DateTime.now.strftime("%Y-%m-%d %H:%M:%S"),
      :id              => 1,
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
