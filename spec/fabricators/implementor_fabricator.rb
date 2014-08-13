require 'hashie/mash'

# Fabricates test manifests (.polytrix.yml files)
LANGUAGES = %w(java ruby python nodejs c# golang php)
SAMPLE_NAMES = [
  'hello world',
  'quine',
  'my_kata'
]

Fabricator(:implementor, from: Polytrix::Implementor) do
  initialize_with { @_klass.new to_hash } # Hash based initialization
  language { LANGUAGES.sample }
  name do |attr|
    "my_#{attr[:language]}_project"
  end
  basedir do |attr|
    "sdks/#{attr[:name]}"
  end
end
