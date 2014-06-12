# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'polytrix/version'

Gem::Specification.new do |spec|
  spec.name          = "polytrix"
  spec.version       = Polytrix::VERSION
  spec.authors       = ["Max Lincoln"]
  spec.email         = ["max@devopsy.com"]
  spec.summary       = %q{A polyglot test runner for sample code}
  spec.description   = %q{A polyglot test runner for sample code}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mixlib-shellout", "~> 1.3"
  spec.add_dependency "middleware", "~> 0.1"
  spec.add_dependency "rspec", "~> 2.14"
  spec.add_dependency "hashie", "~> 2.1"
  spec.add_dependency "padrino-helpers", "~> 0.12"
  # We don't really need a Markdown processor, but Rocco won't load without one
  spec.add_dependency "rdiscount", "~> 2.1"
  spec.add_dependency "rocco", "~> 0.8"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "aruba", "~> 0.5"
  spec.add_development_dependency 'rubocop', '~> 0.18.0'
end
