# Fabricates test manifests (.polytrix.yml files)

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
