require 'spec_helper'

describe Payzilla::Gateways::Rapida do
  before(:all) do
    config = ConfigStub.new('rapida')

    config.setting_url           = 'https://gate.rapida.ru/test/'
    config.setting_key_password  = 'processing5x'

    config.attachment_cert = File.new('certificates/rapida.cer')
    config.attachment_key  = File.new('certificates/rapida.key')

    @transport = Payzilla::Gateways::Rapida.new(config, './log/rapida.log')
  end

  it "checks" do
    payment = OpenStruct.new(
      :id => Time.now.to_i,
      :gateway_provider_id => '111', # megafon
      :fields => {
        '150' => '9268123698'
      },
      :terminal_id => 1
    )
    result = @transport.check(payment)
    result[:success].should == true
  end

  it "pays" do
    payment = OpenStruct.new(
      :id => Time.now.to_i,
      :gateway_provider_id => '111', # megafon
      :fields => {
        '150' => '9268123698'
      },
      :enrolled_amount => 100,
      :commission_amount => 10,
      :terminal_id => 1
    )
    result = @transport.pay(payment)
    result[:success].should == true
  end

  it "lists providers" do
    providers = @transport.providers
    providers.should be_a_kind_of(Hash)
  end
end