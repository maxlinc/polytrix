require 'spec_helper'

# This is more of an integration test, but makes sure the rspec API is working.
# Expect results to all be pending, because there's no implementors in this proj.

describe 'Katas' do
  code_sample 'Hello World' do |execution_result|
    # You can make assertions about the process using the Mixlib::ShellOut API
    expect(execution_result.process.stdout).to include 'Hello, world!'
    expect(execution_result.process.stderr).to be_empty
    expect(execution_result.process.exitstatus).to eq(0)
  end

  code_sample 'Quine' do |execution_result|
    expect(execution_result.process.stdout).to eq File.read(execution_result.source)
  end
end