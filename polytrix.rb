require 'rspec/autorun'
require 'polytrix/rspec'

Polytrix.implementors = [
  Polytrix::Implementor.new(name: 'polytrix', language: 'ruby', basedir: 'samples/')
]
Polytrix.configuration.default_doc_template = 'samples/_markdown.md'

Polytrix.configure do |polytrix|
  polytrix.test_manifest = 'polytrix.yml'
end
Polytrix.bootstrap
Polytrix.run_tests