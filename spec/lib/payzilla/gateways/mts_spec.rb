require 'spec_helper'
require 'crack'

describe Payzilla::Gateways::Mts do
  before(:all) do
    config = ConfigStub.new('mts')

    config.setting_url                    = 'https://194.54.148.89/PaymentProcessingXMLEndpointTestProxy/TestPaymentProcessorDispatcher'
    config.setting_agent                  = '1380201501'
    config.setting_contract               = '9701113662'
    config.setting_key_password           = 'round'
    config.setting_signature_key_password = 'round'
    config.setting_terminal_prefix        = 'smkiosk'

    config.attachment_cert          = File.new('certificates/mts.pem')
    config.attachment_key           = File.new('certificates/mts.pem')
    config.attachment_signature_key = File.new('certificates/mts.pem')

    @transport = Payzilla::Gateways::Mts.new(config, './log/mts.log')

    @date     = DateTime.now - 1
    @payments = %w(9268123698 9268123698)

    @payments = @payments.each_with_index.map do |x,i|
      OpenStruct.new(
        :id => Time.now.to_i+i,
        :account => x,
        :created_at => @date,
        :enrolled_amount => 100,
        :terminal_id => 1,
        :gateway_provider_id => 'mts'
      )
    end

    @revision = OpenStruct.new(:id => 1, :payments => @payments, :date => @date)
  end

  it "checks" do
    payment = OpenStruct.new(:account => '123')
    @transport.check(payment)[:success].should == false

    result = @transport.check(@payments.first)
    result[:success].should == true
  end

  it "pays" do
    @transport.pay(@payments.first)[:success].should == true
  end

  it "generates revision" do
    data = Crack::XML.parse(@transport.generate_revision(@revision)[1])
    data['comparePacket']['summary']['totalAmountOfPayments'].should == "2"
  end
end