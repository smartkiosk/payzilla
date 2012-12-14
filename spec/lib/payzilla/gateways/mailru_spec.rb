require 'spec_helper'

describe Payzilla::Gateways::Mailru do
  before(:all) do
    config = ConfigStub.new('mailru')

    config.setting_key = "KEY"

    @transport = Payzilla::Gateways::Mailru.new(config, './log/mailru.log')

    @payment   = OpenStruct.new(
      :account         => 1234567891011121,
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
