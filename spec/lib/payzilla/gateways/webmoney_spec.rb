require 'spec_helper'

describe Payzilla::Gateways::Webmoney do
  before(:all) do
    config = ConfigStub.new('webmoney')

    config.setting_wmid         = 273862024286
    config.setting_kiosk_id     = 12345
    config.setting_key_password = "qwerty"

    config.attachment_cert = File.new('certificates/webmoney.cer')
    config.attachment_key  = File.new('certificates/webmoney.key')

    config.switch_test_mode = 1

    @transport = Payzilla::Gateways::Webmoney.new(config, './log/webmoney.log')

    @payment = OpenStruct.new(
      :fields => {
        'phone'          => 123456789,
        'purse'          => "RUR",
        'name'           => "Vasilij Pupkin",
        'passport_serie' => "KB",
        'passport_date'  => "2009-12-12",
      },
      :id              => 1234,
      :enrolled_amount => 100,
    )
  end

  it "checks" do
    @transport.check(@payment)[:success].should == true
  end

  it "pays" do
    @transport.pay(@payment)[:success].should == true
  end
end
