require 'polytrix'

basedir = File.expand_path('..', __FILE__)

Polytrix.configure do |polytrix|
  Dir["#{basedir}/sdks/*"].each do |sdk|
    puts "Loading #{sdk}"
    name = File.basename(sdk)
    polytrix.implementor name: name, basedir: sdk
  end
end
