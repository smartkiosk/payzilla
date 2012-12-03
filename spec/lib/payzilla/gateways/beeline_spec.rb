require 'spec_helper'

describe Payzilla::Gateways::Beeline do
  before(:all) do
    config = ConfigStub.new('beeline')

    config.setting_partner_id       = '939'
    config.setting_payment_point_id = 'test'
    config.setting_url              = 'https://bpxptestpg.beeline.ru'

    config.attachment_wsdl          = File.new('schemas/beeline.wsdl')
    config.attachment_cert          = File.new('certificates/mts.pem')
    config.attachment_key           = File.new('certificates/mts.pem')

    @transport = Payzilla::Gateways::Beeline.new(config, './log/beeline.log')

    @date     = DateTime.now - 1
    @payments = %w(9031234567)

    @payments = @payments.each_with_index.map do |x,i|
      OpenStruct.new(
        :id => Time.now.to_i+i,
        :account => x,
        :created_at => @date,
        :enrolled_amount => 100,
        :paid_amount => 100
      )
    end

    @revision = OpenStruct.new(:id => 1, :payments => @payments, :date => @date)
  end

  it "checks" do
    @transport.check(@payments.first)[:success].should == true
  end

  it "generates revision" do
    data = JSON.parse @transport.generate_revision(@revision)[1]

    data['reconciliationRequest']['partnerId'].should == '939'
  end
end