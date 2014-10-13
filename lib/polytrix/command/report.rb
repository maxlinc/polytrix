module Polytrix
  module Command
    class Report < Thor
      namespace :report

      autoload :Dashboard, 'polytrix/command/reports/dashboard'
      register Dashboard, 'dashboard', 'dashboard', 'Create a report dashboard'
      tasks['dashboard'].options = Dashboard.class_options

      autoload :Code2Doc, 'polytrix/command/reports/code2doc'
      register Code2Doc, 'code2doc', 'code2doc [INSTANCE|REGEXP|all]', 'Generates documenation from sample code for one or more scenarios'
      tasks['code2doc'].options = Code2Doc.class_options

      # FIXME: Help shows unwanted usage, e.g. "polytrix polytrix:command:report:code2_doc"
    end
  end
end
