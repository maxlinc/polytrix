module Polytrix
  module Command
    class Report < Thor
      namespace :report
      # class_option :destination, default: 'reports/'
      autoload :Dashboard, 'polytrix/command/reports/dashboard'
      register Dashboard, 'dashboard', 'dashboard', 'Create a report dashboard'
      tasks['dashboard'].options = Dashboard.class_options
    end
  end
end
