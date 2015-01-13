require 'yaml'

Given(/^the (\w+) project$/) do |sdk|
  FileUtils.mkdir_p "#{current_dir}/sdks"
  FileUtils.cp_r "samples/sdks/#{sdk}", "#{current_dir}/sdks"
end

Given(/^the (\w+) crosstest config$/) do |config|
  FileUtils.cp_r "features/fixtures/configs/#{config}.yml", "#{current_dir}/crosstest.yml"
end

Then(/^the file "(.*?)" should contain yaml matching:$/) do |file, content|
  in_current_dir do
    actual_content = YAML.load(File.read(file))
    expected_content = YAML.load(content)
    expect(actual_content).to eq(expected_content)
  end
end
