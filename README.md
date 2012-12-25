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

To use Payzilla, you should have config, payment and gateway instances. Config can be defined with YAML, or just by passing arguments to the contructor. Payment, which you need to send, can be defined only by passing arguments to the constructor. Sending payment should comprise two steps: check and pay, and the second one should be sent only after successfull check. 

```ruby
    # Create config instance
    config = Payzilla::Config.new("dummy", File.new("config.yaml"))

    # Load attachments
    config.attachment_cert  = File.new("certificates/dummy.cer")
    config.attachment_key   = File.new("certificates/dummy.key")

    # Define payment, that you need to send
    payment = Payzilla::Payment.new(
      :id => 1,
      :accound => 111111111,
      :enrolled_amound => 100
    )

    # Check'n'Pay
    transport = Payzilla::Gateways::Dummy.new(config, './log/dummy.log')
    if transport.check(payment)[:success]
      transport.pay(payment)
    end
```

```yaml
# config.yaml
dummy:
    setting_url:      "https://dummy.com/gateway"
    setting_client:   "JDoe"
    setting_contract: "123456789"
    setting_password: "1234"
```

## Gateways status
* Akado _working_
* Beeline _testing_
* Cyberplat _testing_
* Mailru _testing_
* Matrix _testing_
* Megafon _working_
* MTS _testing_
* Rapida _MRI only_
* Skylink _testing_
* Webmoney _not working_
* Yamoney _testing_
* Yota _not working_

## Credits

<img src="http://roundlake.ru/assets/logo.png" align="right" />

* Boris Staal ([@_inossidabile](http://twitter.com/#!/_inossidabile))
* Vasilij Melnychuk ([@sqrel](http://twitter.com/#!/sqrel))

## Contributors

* Byteg ([@bypeg](https://github.com/byteg))
* Alexander Pavlenko ([@AlexanderPavlenko](https://github.com/AlexanderPavlenko))

## LICENSE

It is free software, and may be redistributed under the terms of MIT license.
