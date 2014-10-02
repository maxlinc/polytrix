module Polytrix
  module Command
    class Report < Thor
      namespace :report
      # class_option :destination, default: 'reports/'
      autoload :Summary, 'polytrix/command/reports/summary'
      register Summary, 'summary', 'summary', 'Create a summary report'
      tasks['summary'].options = Summary.class_options
    end
  end
end
