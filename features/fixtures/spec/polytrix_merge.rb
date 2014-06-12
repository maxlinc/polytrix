require 'polytrix'

File.open('reports/polytrix.yaml', 'wb') do |f|
  f.write Polytrix.merge_results(ARGV)
end
