require 'spec_helper'

describe Payzilla::Gateways::Gorod do
  before(:all) do
    config = ConfigStub.new('gorod')

    config.setting_domain       = 'https://194.85.126.106:4567'
    config.setting_password     = '1234'

    config.attachment_cert = File.new('certificates/gorod.pem')
    config.attachment_key  = File.new('certificates/gorod.pem')

    @transport = Payzilla::Gateways::Gorod.new(config, './log/gorod.log')

    @services = %w(515 615)

    @services = @services.each_with_index.map do |x,i|
      OpenStruct.new(
        :service         => x,
        :account         => 9026475359,
        :enrolled_amount => 100,
      )
    end
  end

  it "checks" do
    @transport.check(@payments.first)[:success].should == true

    payment = OpenStruct.new(:account => '123')
    @transport.check(payment)[:success].should == false
  end

  it "pays" do
    @transport.pay(@payments.first)[:success].should == true
  end
end
