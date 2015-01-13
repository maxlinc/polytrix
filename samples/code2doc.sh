#!/usr/bin/env bash -e
bundle exec crosstest generate code2doc java --destination=docs/code2doc/java
bundle exec crosstest generate code2doc python --destination=docs/code2doc/python
bundle exec crosstest generate code2doc ruby --destination=docs/code2doc/ruby
