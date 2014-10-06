require 'json'
require 'polytrix/reporters'

module Polytrix
  module Command
    class Report
      class Summary < Thor::Group
        include Thor::Actions
        include Polytrix::Core::FileSystemHelper
        module Helpers
          def implementors
            Polytrix.implementors.map do |implementor|
              slug(implementor.name)
            end
          end

          def results
            manifest = Polytrix.manifest
            results = []
            grouped_challenges = manifest.challenges.values.group_by { |challenge| [challenge.suite, challenge.name] }
            grouped_challenges.each do |(suite, name), challenges|
              row = {
                suite: suite,
                scenario: name
              }
              Polytrix.implementors.each do |implementor|
                challenge = challenges.find { |c| c.implementor == implementor }
                row[slug(implementor.name)] = challenge.display_status
              end
              results << row
            end
            results
          end

          def as_json(table)
            JSON.dump(table)
          end

          def slug(label)
            label.gsub('.', '_').gsub('-', '_')
          end

          def verification_message(challenge)
            validator_count = challenge.validators.count
            validation_count = challenge.validators.count
            if validator_count == validation_count
              "Fully Verified (#{validation_count} of #{validator_count})"
            else
              "Partially Verified (#{validation_count} of #{validator_count})"
            end
          end
        end
        include Helpers

        class_option :destination, default: 'reports/'

        def self.source_root
          Polytrix::Reporters::TEMPLATE_DIR
        end

        def report_name
          @report_name ||= self.class.name.downcase.split('::').last
        end

        def add_framework_to_source_root
          source_paths.map do | path |
            path << "/#{report_name}"
          end
        end

        def set_destination_root
          self.destination_root = options[:destination]
        end

        # def load_helpers
        #   framework_root = source_paths.first
        #   Dir["#{report_name}/helpers/**/*.rb"].each do |helper|
        #     load helper
        #   end
        # end

        def setup
          Polytrix.manifest.build_challenges
          test_dir = 'tests/polytrix' # @test_dir.nil? ? nil : File.expand_path(@test_dir)
          if test_dir && File.directory?(test_dir)
            $LOAD_PATH.unshift test_dir
            Dir["#{test_dir}/**/*.rb"].each do | file_to_require |
              require relativize(file_to_require, test_dir).to_s.gsub('.rb', '')
            end
          end
        end

        def copy_base_structure
          directory 'files', '.'
        end

        def create_spy_reports
          reports = Polytrix::Spies.reports[:summary]
          reports.each do | report_class |
            invoke report_class, args, options
          end if reports
        end
      end
    end
  end
end
