module Polytrix
  module Command
    class Generate < Thor
      namespace :generate

      autoload :Dashboard, 'polytrix/command/generators/dashboard'
      register Dashboard, 'dashboard', 'dashboard', 'Create a report dashboard'
      tasks['dashboard'].options = Dashboard.class_options

      autoload :Code2Doc, 'polytrix/command/generators/code2doc'
      register Code2Doc, 'code2doc', 'code2doc [PROJECT|REGEXP|all] [SCENARIO|REGEXP|all]',
               'Generates documenation from sample code for one or more scenarios'
      tasks['code2doc'].options = Code2Doc.class_options

      autoload :Documentation, 'polytrix/command/generators/documentation'
      register Documentation, 'docs', 'docs', 'Generate documentation from a template'
      tasks['docs'].options = Documentation.class_options
      tasks['docs'].long_description = <<-eos
      Generates documentation from a template. The templates may use Thor actions and Padrino helpers
      in order to inject data from Polytrix test runs, code samples, or other sources.

      Available templates: #{Documentation.generator_names.join(', ')}
      eos

      # FIXME: Help shows unwanted usage, e.g. "polytrix polytrix:command:report:code2_doc"
    end
  end
end
