#!/usr/bin/env ruby

require 'polytrix'

Polytrix.configure do |polytrix|
  Dir['../features/fixtures/sdks/*'].each do |sdk|
    name = File.basename(sdk)
    polytrix.implementor name: name, basedir: sdk
  end
end
Polytrix.bootstrap
