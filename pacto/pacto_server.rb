require 'goliath'
require 'em-synchrony'
require 'em-synchrony/em-http'

class PactoServer < Goliath::API
  use Goliath::Rack::Params
  PORT = 9900

  def response (env)
    path = env[Goliath::Request::REQUEST_PATH]
    host = env['HTTP_HOST'].gsub(".dev:#{PORT}", '.com')
    headers = env['client-headers']
    begin
      uri = "https://#{host}#{path}"
      env.logger.info 'forwarding to: ' + uri
      safe_headers = headers.reject {|k,v| ['host', 'content-length'].include? k.downcase }
      env.logger.debug "filtered headers: #{safe_headers}"
      if env['REQUEST_METHOD'] == 'POST'
        env.logger.debug "sending post request"
        body = env[Goliath::Request::RACK_INPUT].read
        env.logger.debug "sending body: #{body}"
        resp = EM::Synchrony.sync EventMachine::HttpRequest.new(uri).apost(head: safe_headers, body: body)
      else
        env.logger.debug "sending get request"

        resp = EM::Synchrony.sync EventMachine::HttpRequest.new(uri).aget(head: safe_headers, query: env.params)
      end
      code = resp.response_header.http_status
      safe_response_headers = normalize_headers(resp.response_header).reject {|k,v| ['connection', 'content-encoding', 'content-length', 'transfer-encoding'].include? k.downcase}
      body = proxy_rewrite(resp.response)
      env.logger.debug "response headers: #{safe_response_headers}"
      env.logger.debug "response body: #{body}"
      [code, safe_response_headers, body]
    rescue => e
      [500, {}, e.message]
    end
  end

  def normalize_headers headers
    headers.inject({}) do |res, elem|
      key = elem.first.dup
      value = elem.last
      key.gsub!('_', '-')
      key = key.split('-').map {|w| w.capitalize}.join '-'
      res[key] = value
      res
    end
  end

  def proxy_rewrite body
    # Make sure rels continue going through our proxy
    body.gsub('.com', ".dev:#{PORT}").gsub(/https\:([\w\-\.\\\/]+).dev/, 'http:\1.dev')
  end

  def options_parser(opts, options)
    options[:strict] ||= false
    options[:directory] ||= "contracts"
    opts.on('-l', '--live', 'Send requests to live services (instead of stubs)') { |val| options[:live] = true }
    opts.on('-g', '--generate', 'Generate Contracts from requests') { |val| options[:generate] = true }
    opts.on('-V', '--validate', 'Validate requests/responses against Contracts') { |val| options[:validate] = true }
    opts.on('-m', '--match-strict', 'Enforce strict request matching rules') { |val| options[:strict] = true }
    opts.on('-x', '--contracts_dir DIR', 'Directory that contains the contracts to be registered') { |val| options[:directory] = val }
    opts.on('-H', '--host HOST', 'Host of the real service, for generating or validating live requests') { |val| options[:backend_host] = val }
  end

  def on_headers(env, headers)
    env.logger.info 'proxying new request: ' + headers.inspect
    env['client-headers'] = headers
  end

end
