require 'spec_helper'
require 'yaml'
require 'csv'

class CSVFeatureMatrix
  def initialize(matrix_csv)
    @feature_matrix = []

    CSV.foreach(matrix_csv, :headers => :first_row) do |row|
      
      # Carry the product
      @product = row['Product'] if row['Product']
      row['Product'] ||= @product

      next if row['Feature'].nil? or row['Feature'].empty?

      # Normalize status
      SDKs.each do |sdk|
        row[sdk] = '' unless row[sdk] == 'Done'
      end

      @feature_matrix << row.to_hash
    end
  end

  def products
    @feature_matrix.map{|f| f['Product']}.uniq.compact
  end

  def features(product)
    @feature_matrix.select{|f| f['Product'] == product}.map{|f| f['Feature']}.compact
  end

  def implementers product, service_name
    code_sample = @feature_matrix.find{|f| f['Feature'] == service_name}
    feature.keys.select{|k| feature[k] == 'Done'}
  end
end

class CoveredFeatures
  def initialize(coverage_files)
    @coverage = {}
    @covered_features = {}
    [*coverage_files].each do |file|
      @coverage.merge! YAML::load(File.read(file))
    end
    @coverage.values.flatten.uniq do |covered_feature|
      @covered_features[covered_feature] = SDKs.select{|sdk|
        @coverage.select{|k,v| k =~ /#{sdk}$/}.values.flatten.include? covered_feature
      }
    end
  end

  def coverers(product, feature)
    @covered_features[feature] || []
  end
end

sdk_coverage = CoveredFeatures.new(Dir['reports/api_coverage*.yaml'])
original_feature_matrix = CSVFeatureMatrix.new 'original_feature_matrix.csv'

original_feature_matrix.products.each do |product|
  describe product do
    original_feature_matrix.features(product).each do |feature|
      describe feature do
        coverers = sdk_coverage.coverers(product, feature)
        implementers = original_feature_matrix.implementers(product,feature)
        SDKs.each do |sdk|
          it sdk, sdk.to_sym do
            if coverers.include? sdk
              # pass
            else
              if implementers.include? sdk
                pending
              else
                fail
              end
            end
          end
        end
      end
    end
  end
end

# data = YAML::load(File.read('pacto/rackspace_uri_map.yaml'))
# data['services'].each do |service_group_name, service_group|
#   describe service_group_name do
#     services = service_group['services'] || []
#     services.each do |service_name, service|
#       describe service_name do
#         SDKs.each do |sdk|
#           it sdk, sdk.to_sym do
#             sdk_coverage = coverage.select{|k,v| k =~ /#{sdk}$/ }
#             if sdk_coverage.values.flatten.include? service_name
#               # pass
#             else
#               if original_feature_matrix.implemented? service_name, sdk
#                 pending
#               else
#                 fail
#               end
#             end
#           end
#         end
#       end
#     end
#   end
# end
