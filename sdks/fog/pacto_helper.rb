pacto_mode = ENV['PACTO_MODE'] || 'validate'
Pacto.generate! if pacto_mode == 'generate'
Pacto.validate! if pacto_mode == 'validate' || pacto_mode == 'stub'

contracts_path = File.expand_path '../../pacto/contracts', Dir.pwd
Pacto.configure do |config|
  config.contracts_path = contracts_path
  config.strict_matchers = false
  config.generator_options = {:schema_version => :draft3, :defaults => true}
end
if Pacto.generating?
  WebMock.allow_net_connect!
  Pacto.generate!
else
  Dir["#{contracts_path}/*"].each do |host|
    host = File.basename host
    Pacto.load_all host, "https://#{host}", host
    Pacto.use host
  end
  unless pacto_mode == 'stub'
    WebMock.reset!
    WebMock.allow_net_connect!
  end
end
