#!/usr/bin/env bash -e
bundle exec polytrix report code2doc java --destination=docs/code2doc/java
bundle exec polytrix report code2doc python --destination=docs/code2doc/python
bundle exec polytrix report code2doc ruby --destination=docs/code2doc/ruby
