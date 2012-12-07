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
        :enrollerd_amount => 10000,
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
    @transport.revise(@payments, DateTime.now)[:success].should == true
  end
end
