require 'yaml'

Given(/^the (\w+) SDK$/) do |sdk|
  FileUtils.mkdir_p "#{current_dir}/sdks"
  FileUtils.cp_r "samples/sdks/#{sdk}", "#{current_dir}/sdks"
end

Given(/^the (\w+) polytrix config$/) do |config|
  FileUtils.cp_r "features/fixtures/configs/#{config}.yml", "#{current_dir}/polytrix.yml"
end

Given(/^the standard rspec setup$/) do
  FileUtils.cp_r 'features/fixtures/spec/', "#{current_dir}/"
end

Then(/^the file "(.*?)" should contain yaml matching:$/) do |file, content|
  in_current_dir do
    actual_content = YAML.load(File.read(file))
    expected_content = YAML.load(content)
    expect(actual_content).to eq(expected_content)
  end
end
