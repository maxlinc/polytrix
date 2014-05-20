require 'rspec/autorun'
require 'polytrix/rspec'

Polytrix.implementors = [
  Polytrix::Implementor.new(name: 'polytrix', language: 'ruby', basedir: 'samples/')
]
Polytrix.configuration.default_doc_template = 'samples/_markdown.md'

Polytrix.load_manifest 'polytrix.yml'
Polytrix.bootstrap
Polytrix.run_tests