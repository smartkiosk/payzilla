require 'spec_helper'

describe Payzilla::Gateways::Skylink do
  before(:all) do
    config = ConfigStub.new('skylink')

    config.setting_url    = "https://pay.msk.skylink.ru/srv_main_v2.asmx"
    config.setting_client = 4

    @payments = %w(9015041214 4959781777)
    @payments = @payments.map do |p|
      OpenStruct.new(
        :account => p,
        :paid_amount => 100,
        :enrolled_amount => 100,
        :created_at => DateTime.now,
        :id => 1
      )
    end

    @transport = Payzilla::Gateways::Skylink.new(config, './log/skylink.log')
  end

  it "checks" do
    @payments.each do |payment|
      @transport.check(payment)[:success].should == true
    end
  end

  it "pays" do
    @payments.each do |payment|
      @transport.pay(payment)[:success].should == true
    end
  end

  it "revises" do
    @transport.revise(@payments, Time.now - 86400)[:success].should == true
  end
end
