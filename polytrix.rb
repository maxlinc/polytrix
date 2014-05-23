require 'rspec/autorun'
require 'polytrix/rspec'

Polytrix.configuration.default_doc_template = 'doc-src/_markdown.md'

Polytrix.configure do |polytrix|
  polytrix.test_manifest = 'polytrix.yml'
  polytrix.implementor name: 'polytrix', language: 'ruby', basedir: 'samples/'
end
Polytrix.bootstrap
Polytrix.run_tests