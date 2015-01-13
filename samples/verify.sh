#!/usr/bin/env bash -e
bundle exec crosstest destroy
bundle exec crosstest verify
