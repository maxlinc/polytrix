#!/usr/bin/env bash -e
bundle exec polytrix bootstrap
bundle exec polytrix exec sdks/ruby/challenges/*.rb --code2doc --target-dir=docs/ruby/
# bundle exec polytrix test
bundle exec polytrix report summary
bundle exec polytrix report summary --format=markdown
bundle exec polytrix report summary --format=yaml
