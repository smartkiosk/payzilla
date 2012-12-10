require 'spec_helper'

describe Payzilla::Gateways::Osmp do
  before(:all) do
    config = ConfigStub.new('osmp')
    config.setting_domain    = 'http://xml1.osmp.ru/xmlgate/xml.jsp'
    config.setting_client    = '44'
    config.setting_password  = 'vC2VNgAv'
    config.setting_terminal  = 'MKB'

    @payment = OpenStruct.new(
      :id => 1,
      :account => 8888888888,
      :paid_amount => '1',
      :enrolled_amount => '1',
      :gateway_provider_id => 44,
    )

    @transport = Payzilla::Gateways::Osmp.new(config, './log/osmp.log')
  end

  it "checks" do
    @transport.check(@payment)[:success].should == true
  end

  it "pays" do
    @transport.pay(@payment)[:success].should == true
  end
end

