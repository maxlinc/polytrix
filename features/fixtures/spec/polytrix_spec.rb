require 'spec_helper'

Polytrix.load_manifest 'polytrix.yml'
Polytrix.bootstrap
Polytrix.run_tests