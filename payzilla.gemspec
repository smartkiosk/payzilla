# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'payzilla/version'

Gem::Specification.new do |gem|
  gem.name          = "payzilla"
  gem.version       = Payzilla::VERSION
  gem.authors       = ["Boris Staal"]
  gem.email         = ["boris@roundlake.ru"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'rake'
  gem.add_dependency 'json'
  gem.add_dependency 'rest-client'
  gem.add_dependency 'crack'
  gem.add_dependency 'savon'
  gem.add_dependency 'cyberplat_pki'
  gem.add_dependency 'webmoney', '0.0.15.pre'
  gem.add_dependency 'gyoku'
  gem.add_dependency 'gpgme-ffi'

  ['pry', 'rspec'].each do |dep|
    gem.add_development_dependency(dep)
  end
end
