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
  end

  xit "checks" do
    payment = OpenStruct.new(:account => '9268123698')
    @transport.check(payment)[:success].should == true

    payment = OpenStruct.new(:account => '123')
    @transport.check(payment)[:success].should == false
  end

  xit "pays" do
    payment = OpenStruct.new(:id => Time.now.to_i, :account => '9268123698', :enrolled_amount => 100)
    @transport.pay(payment)[:success].should == true
  end

  it "revises" do
    payments = []
    date     = DateTime.now - 1

    5.times do
      payments << OpenStruct.new(:id => Time.now.to_i, :account => '9268123698', :enrolled_amount => 100, :created_at => date)
    end

    revision = OpenStruct.new(:payments => payments, :date => date)

    @transport.revise(revision)[:success].should == true
  end
end
