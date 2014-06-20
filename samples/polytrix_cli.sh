#!/usr/bin/env bash
bundle exec polytrix bootstrap
bundle exec polytrix exec sdks/ruby/challenges/*.rb --code2doc --target-dir=docs/ruby/
