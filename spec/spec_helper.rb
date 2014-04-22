$:.unshift File.expand_path('../pacto', File.dirname(__FILE__))
require 'polytrix/rspec'
require 'webmock/rspec'
require 'matrix_formatter'
require 'helpers/pacto_helper'
require 'pacto/extensions/matchers'
require 'pacto/extensions/loaders/simple_loader'
require 'pacto/extensions/loaders/api_blueprint_loader'
require 'helpers/teardown_helper'
require 'helpers/cloudfiles_helper'

SDKs = Dir['sdks/*'].map{|sdk| File.basename sdk}

Polytrix.implementors = SDKs

RSpec.configure do |c|
  c.matrix_implementors = SDKs
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.include Polytrix::RSpec
end

def standard_env_vars
  @standard_env_vars ||= {
    'RAX_USERNAME'   => ENV['RAX_USERNAME'],
    'RAX_API_KEY'    => ENV['RAX_API_KEY'],
    'RAX_REGION'     => 'ORD', # FIXME: stubbing multiple hosts
    # 'RAX_REGION'     => ENV['RAX_REGION'] || %w{DFW ORD IAD SYD HKG}.sample, # omitted LON since it requires UK account
    'RAX_AUTH_URL'   => PACTO_SERVER || 'https://identity.api.rackspacecloud.com'
  }
end

def redact(data)
  Hash[data.map do |k,v|
    if k =~ /password|api_key/i
      v = '******'
    end
    [k, v]
  end]
end
