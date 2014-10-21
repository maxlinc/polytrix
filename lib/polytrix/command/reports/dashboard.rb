require 'json'
require 'polytrix/reporters'

module Polytrix
  module Command
    class Report
      class Dashboard < Thor::Group
        include Thor::Actions
        include Polytrix::Util::FileSystem
        module Helpers
          include Polytrix::Util::String
          include Padrino::Helpers::TagHelpers
          include Padrino::Helpers::OutputHelpers
          include Padrino::Helpers::AssetTagHelpers

          def implementors
            Polytrix.implementors.map do |implementor|
              slugify(implementor.name)
            end
          end

          def results
            manifest = Polytrix.manifest
            rows = []
            grouped_challenges = manifest.challenges.values.group_by { |challenge| [challenge.suite, challenge.name] }
            grouped_challenges.each do |(suite, name), challenges|
              row = {
                slug_prefix: slugify(suite, name),
                suite: suite,
                scenario: name
              }
              Polytrix.implementors.each do |implementor|
                challenge = challenges.find { |c| c.implementor == implementor }
                row[slugify(implementor.name)] = challenge.status_description
              end
              rows << row
            end
            rows
          end

          def as_json(table)
            JSON.dump(table)
          end

          def status(status, msg = nil, _color = :cyan)
            "<strong>#{status}</strong> <em>#{msg}</em>"
          end

          def bootstrap_color(color)
            bootstrap_classes = {
              green: 'success',
              cyan: 'primary',
              red: 'danger',
              yellow: 'warning'
            }
            bootstrap_classes.key?(color) ? bootstrap_classes[color] : color
          end
        end

        include Helpers

        class_option :destination, default: 'reports/'
        class_option :code_style, default: 'github'

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
          return nil unless test_dir && File.directory?(test_dir)

          $LOAD_PATH.unshift test_dir
          Dir["#{test_dir}/**/*.rb"].each do | file_to_require |
            require relativize(file_to_require, test_dir).to_s.gsub('.rb', '')
          end
        end

        def copy_assets
          directory Polytrix::Reporters::ASSETS_DIR, 'assets'
        end

        def copy_base_structure
          directory 'files', '.'
        end

        def create_test_reports
          Polytrix.manifest.challenges.values.each do |challenge|
            @challenge = challenge
            template 'templates/_test_report.html.tt', "details/#{challenge.slug}.html"
          end
        end

        def create_spy_reports
          reports = Polytrix::Spies.reports[:dashboard]
          reports.each do | report_class |
            invoke report_class, args, options
          end if reports
        end
      end
    end
  end
end
