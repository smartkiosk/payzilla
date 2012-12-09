require 'spec_helper'
require 'crack'

describe Payzilla::Gateways::Mts do
  before(:all) do
    config = ConfigStub.new('mts')

    config.setting_url                    = 'https://194.54.148.89/PaymentProcessingXMLEndpointTestProxy/TestPaymentProcessorDispatcher'
    config.setting_agent                  = '13802005013'
    config.setting_contract               = '97018117111'
    config.setting_key_password           = 'round'
    config.setting_signature_key_password = 'round'
    config.setting_terminal_prefix        = 'smkiosk'

    config.attachment_cert          = File.new('certificates/mtscert.pem')
    config.attachment_key           = File.new('certificates/mtscert.pem')
    config.attachment_signature_key = File.new('certificates/mtscert.pem')

    @transport = Payzilla::Gateways::Mts.new(config, './log/mts.log')

    @date     = DateTime.now - 1
    @payments = %w(0950000001 0950000002 0950000003 0950000004 0950000005 0950000006 0950000007 0950000008 0950000009 0950000010 0950000011 0950000012 0950000013 0950000014 0950000015 0950000016 0950000017 0950000018 0950000019 0950000025 0950000026 0950000027 0950000030 0950000056)

    @payments = @payments.each_with_index.map do |x,i|
      OpenStruct.new(
        :id => Time.now.to_i+i,
        :account => x,
        :created_at => @date,
        :enrolled_amount => 100,
        :terminal_id => 1,
        :gateway_provider_id => 'MTS'
      )
    end

    @revision = OpenStruct.new(:id => 1, :payments => @payments, :date => @date)
  end

  it "checks" do
    payment = OpenStruct.new(:account => '123')
    @transport.check(payment)[:success].should == false

    # @payments.each do |pay|
    #   #result = @transport.check(pay)
    #   #result[:success].should == true
    #   puts @transport.check(pay)
    #   puts "    "
    #   puts pay.account
    # end
  end

  #it "pays" do
  #  @transport.pay(@payments.first)[:success].should == true
  #end

  #it "generates revision" do
  #  data = Crack::XML.parse(@transport.generate_revision(@revision)[1])
  #  data['comparePacket']['summary']['totalAmountOfPayments'].should == "2"
  #end
end
