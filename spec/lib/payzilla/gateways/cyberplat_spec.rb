require 'spec_helper'

describe Payzilla::Gateways::Cyberplat do
  before(:all) do
    config = ConfigStub.new('cyberplat')

    config.setting_host         = 'service.cyberplat.ru'
    config.setting_operator     = '1007026'
    config.setting_point        = '1007030'
    config.setting_key_password = '11111%%%'

    config.attachment_private_key = File.new('certificates/cyberplat.priv.key')
    config.attachment_public_key  = File.new('certificates/cyberplat.pub.key')

    @transport = Payzilla::Gateways::Cyberplat.new(config, './log/cyberplat.log')
  end

  it "checks" do
    payment = OpenStruct.new(
      :id => Time.now.to_i,
      :gateway_provider_id => 'mb',
      :account => '9268888888',
      :fields => {},
      :terminal_id => 1,
      :agent_id => 1
    )
    result = @transport.check(payment)
    result[:success].should == true
  end

  it "pays" do
    payment = OpenStruct.new(
      :id => Time.now.to_i,
      :gateway_provider_id => 'mb',
      :account => '9268888888',
      :fields => {},
      :terminal_id => 1,
      :agent_id => 1,
      :enrolled_amount => 100
    )
    result = @transport.pay(payment)
    result[:success].should == true
  end
end