require 'spec_helper'

describe Payzilla::Gateways::Megafon do
  before(:all) do
    config = ConfigStub.new('megafon')

    config.setting_domain       = '193.201.228.9'
    config.setting_client       = 'MKB'
    config.setting_password     = '1234'

    config.attachment_cert = File.new('certificates/megafon.cer')
    config.attachment_key  = File.new('certificates/megafon.key')

    @transport = Payzilla::Gateways::Megafon.new(config, './log/megafon.log')

    @date     = DateTime.now
    @payments = %w(9268123698)

    @payments = @payments.each_with_index.map do |x,i|
      OpenStruct.new(
        :id => Time.now.to_i+i,
        :account => x,
        :enrolled_amount => 100,
        :created_at => @date
      )
    end

    @revision = OpenStruct.new(:id => Time.now.to_i, :payments => @payments, :date => @date.to_date)
  end

  it "checks" do
    @transport.check(@payments.first)[:success].should == true

    payment = OpenStruct.new(:account => '123')
    @transport.check(payment)[:success].should == false
  end

  it "pays" do
    @transport.pay(@payments.first)[:success].should == true
  end

  it "revises" do
    @transport.revise(@revision)[:success].should == true
  end
end
