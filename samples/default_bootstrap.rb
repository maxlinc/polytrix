#!/usr/bin/env ruby

# This example shows the default behavior of `Polytrix#bootstrap`
require 'polytrix'

Polytrix.configure do |polytrix|
  Dir['sdks/*'].each do |sdk|
    name = File.basename(sdk)
    polytrix.implementor name: name, basedir: sdk
  end
end

# Snippet: bootstrap
Polytrix.bootstrap
