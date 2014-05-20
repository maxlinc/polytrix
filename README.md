# Polytrix - the Polyglot Testing Matrix

Polytrix is a polyglot test runner and documentation generator. It aims to let you run sample code written in any language. It's especially useful if you want to run similar code samples in multiple languages. Simply put, if a project like [Slate](https://github.com/tripit/slate) looks like an interesting documentation option, then you might be interested in Polytrix for testing.

# Features

Polytrix samples defined in a "test manifest" written in YAML. The test manifest is meant to be portable so you can use you can create a "lightweight sample runner" in your preferred build/test tool of choice for your language, and then integrate the samples with Polytrix later to get the extra features. Polytrix can:
- Run sample code in any language and several platforms
- Perform compatibility testing checking multiple implementations (in different langauges) against the same set of assertions
- Generate documentation from sample code and test results
- Generate compatibility or feature matrix reports

Polytrix provides a few built-in assertions, but also has a plugin system that you can use to do more advanced validation, like using [Pacto](https://github.com/thoughtworks/pacto) to intercept and validate the usage of RESTful services.

# Usage preview

Polytrix is currently run via rspec. You can create a script that looks like this and run it with rspec:

```ruby
require 'polytrix/rspec'

Polytrix.implementors = Dir['sdks/*'].map{ |sdk|
  name = File.basename(sdk)
  Polytrix::Implementor.new :name => name
}

Polytrix.load_manifest 'polytrix.yml'
Polytrix.bootstrap
Polytrix.run_tests
```

Polytrix will use the information in the Manifest and Implementors (see the sections below) to build an rspec test suite. It will setup tags for each Implementor, and names corresponding with the tests in the manifest.

So in our Polytrix examples project you can use commands like:

```sh
$ # Only run tests for the Java implementor
$ bundle exec rspec -t java
$ # Run the "hello world" tests in each language
$ bundle exec rspec -e "hello world"
```

## Usage Breakdown

### Defining Implementors (SDKs)

Polytrix can run the tests against multiple implementors. This usually means an SDK, but we used the generic term implementor because Polytrix works equally well for testing code katas, coursework, or other items. Perhaps even things like multi-platform plugins for [Calatrava](https://github.com/calatrava/calatrava/wiki/Plugins) or [PhoneGap](http://docs.phonegap.com/en/3.4.0/guide_hybrid_plugins_index.md.html#Plugin%20Development%20Guide).

This snippet defines the implementors:
```ruby
Polytrix.implementors = Dir['sdks/*'].map{ |sdk|
  name = File.basename(sdk)
  Polytrix::Implementor.new :name => name
}
```

See the full Implementor documentation for details on other attributes you can set, like `:language`. Polytrix will try to infer any information you don't pass.

#### Bootstrapping, compiling, wrapper scripts

Polytrix currently uses the [script/bootstrap](http://wynnnetherland.com/linked/2013012801/bootstrapping-consistency) pattern to allow each implementor to hook into dependency management, build tools, or other systems. Polytrix will look for three scripts (on Windows it will look for a *.ps1 version written in PowerShell):

| File             | Purpose                                                        |
| ---------------- | -------------------------------------------------------------- |
| script/bootstrap | Prepare the SDK, usually by running depenency management tool. |
| script/wrapper   | Wrapper script instead of executing code samples as scripts    |

The bootstrap script is called by `Polytrix.bootstrap`. The wrapper script, if it exists, wraps the executino of the code sample. If there is no wrapper script, Polytrix will try to execute the sample code as a script. That works for many non-compiled scripting languages, like Ruby or Python, but won't work for something like Java.

If there is a wrapper script, Polytrix will call it with teh sample source file as the first argument, e.g.:
```sh
$ cd my_java_sdk
$ ./script/wrapper src/samples/HelloWorld.java
```

### Defining tests - the test manifest

Tests are defined in a YAML "test manifest" which defines what sample code should be executed, and what input it should receive. Standardizing the input is important for compliance testing, becaues it is difficult to maintain tests where one example expects "FOO=bar" and another expects "--foo bar".

A simple test manifest looks like this:
```yaml
---
  global_env:                          # global_env defines input available for all scenarios
    LOCALE: <%= ENV['LANG'] %>         # templating is allowed
    FAVORITE_NUMBER: 5
  suites:                              # suites defines the test suites that can be executed
    Katas:                             # "Katas" is the name of the first suite
      env:                             # These "env" values are only available within the "Katas" suite
        NAME: 'Max'
      samples:                         # samples defines the individual tests in a suite
        - hello world
        - quine
    Tutorials:                         # "Tutorials" is the name of the second suite
          env:
          samples:
            - deploying
            - documenting
```

### Test setup

`Polytrix.run_tests` runs the tests. Actually, right now it really just defines them in rspec, you still need to run the whole script via the RSpec command for the tests to run.

### Finding samples

Polytrix finds samples based on a loose naming convention. This makes it easier to use file names that are idiomatic for each implementor, while still allowing Polytrix to find the right file.

Polytrix basically does a case-insensitive search for a file whose name matches the scenario name, ignoring subfolders, spaces, prefixes, puctuation and file extension.  So these files all match a scenario named "hello world":
- hello_world.rb
- src/com/world/HelloWorld.java
- samples/01_hello_world.go

### Reports and documentation

Polytrix can generate reports and documentation after running the tests. You can generate:
- Scenario-level reports: Documentation or reports for a single scenario
- Global reports: Documentation or reports summarizing all tested scenarios

The documentatio/reports are generated via a template processing system. Polytrix searches the template directory ('doc-src/' by default) for scenario-level samples using the same logic as in the "Finding samples" section above. It looks for a template matching "index" (e.g. index.md, index.rst, index.html) for the global report.

The templates are processed as ERB. In addition to being able to access the top-level Polytrix API, the following variables are bound:
| Variable   | Description                              |
| ---------- | ---------------------------------------- |
| scenario   | The name of the scenario being processed |
| challenges | One or more Challenge objects containing the scenario configuration and results |

### Common compliance tests

Refactoring... documentation coming soon.

### Plugins

Refactoring... documentation coming soon.

# Influences

Several projects have influenced ideas in Polytrix. If you find Polytrix interesting or want to contribute, you may want to look at those projects. See influence.md.