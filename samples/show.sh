#!/usr/bin/env bash -e
bundle exec polytrix destroy
bundle exec polytrix test ruby
bundle exec polytrix show katas-hello_world-ruby
