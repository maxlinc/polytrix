#!/usr/bin/env bash -e
bundle exec polytrix destroy
bundle exec polytrix test ruby
bundle exec polytrix show ruby 'hello world'
