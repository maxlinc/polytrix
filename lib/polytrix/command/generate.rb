module Polytrix
  module Command
    class Generate < Thor
      namespace :generate

      autoload :Dashboard, 'polytrix/command/generators/dashboard'
      register Dashboard, 'dashboard', 'dashboard', 'Create a report dashboard'
      tasks['dashboard'].options = Dashboard.class_options

      autoload :Code2Doc, 'polytrix/command/generators/code2doc'
      register Code2Doc, 'code2doc', 'code2doc [INSTANCE|REGEXP|all]', 'Generates documenation from sample code for one or more scenarios'
      tasks['code2doc'].options = Code2Doc.class_options

      # FIXME: Help shows unwanted usage, e.g. "polytrix polytrix:command:report:code2_doc"
    end
  end
end
