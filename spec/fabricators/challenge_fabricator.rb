require 'hashie/mash'

# Fabricates test manifests (.polytrix_tests.yml files)
LANGUAGES = %w(java ruby python nodejs c# golang php)
SAMPLE_NAMES = [
  'hello world',
  'quine',
  'my_kata'
]

Fabricator(:challenge, from: Polytrix::Challenge) do
  initialize_with { @_klass.new to_hash } # Hash based initialization
  name { SAMPLE_NAMES.sample }
  suite { LANGUAGES.sample }
  source_file { 'spec/fixtures/factorial.py' }
  basedir { 'spec/fixtures' }
end
