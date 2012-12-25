# Payzilla

This gem is a set of gateways, that allows you easily send payments to carriers.

## Installation

Add this line to your application's Gemfile:

    gem 'payzilla'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install payzilla

## Usage

First of all you should define configuration of each of the carriers you will use

    config = Payzilla::Config.new("carrier")
    config.setting_domain   = "https://your-carrier.com/"
    config.setting_password = "pass"
    config.attachment_cert  = File.new("certificates/carrier.pem")

Note, that all settings, such as domain name, password has appendix "setting\_", and all of attachments - "attachment\_". You can also export config from YAML file.
Next step is to define payment, that you need to send. It could be done this way:

    payment = Payzilla::Payment.new(
      :id => 1,
      :accound => 111111111,
      :enrolled_amound => 100
    )

After this, you are able to send payment to the carrier, and here how can you do this:

    transport = Payzilla::Gateways::Carrier.new(config, './log/carrier.log')
    transport.check(payment)
    transport.pay(payment)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## LICENSE

It is free software, and may be redistributed under the terms of MIT license.
