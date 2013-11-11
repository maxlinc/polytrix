pacto_mode = ENV['PACTO_MODE']
if pacto_mode
  require 'pacto'

  contracts_path = File.expand_path '../../pacto/contracts', Dir.pwd
  Pacto.configure do |config|
    config.contracts_path = contracts_path
    config.strict_matchers = false
    config.generator_options = {:schema_version => :draft3, :defaults => true}
  end

  case pacto_mode
  when 'generate'
    Pacto.generate!
    WebMock.allow_net_connect!
  when 'validate', 'stub'
    Pacto.validate!

    contracts_path = File.expand_path '../../pacto/contracts', Dir.pwd
    Pacto.configure do |config|
      config.contracts_path = contracts_path
      config.strict_matchers = false
      config.generator_options = {:schema_version => :draft3, :defaults => true}
    end

    Dir["#{contracts_path}/*"].each do |host|
      host = File.basename host
      Pacto.load_all host, "https://#{host}", host
      Pacto.use host
    end

    # Workaround because Pacto doesn't have a proper validate live mode yet
    unless pacto_mode == 'stub'
      WebMock.reset!
      WebMock.allow_net_connect!
    end

  else
    WebMock.allow_net_connect!
  end
end