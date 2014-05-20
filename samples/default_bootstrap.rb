#!/usr/bin/env ruby

require 'polytrix'

Polytrix.implementors = Dir['../features/fixtures/sdks/*'].map{ |sdk|
  name = File.basename(sdk)
  Polytrix::Implementor.new :name => name, :basedir => sdk
}
Polytrix.bootstrap