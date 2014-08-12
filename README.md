# Polytrix - the Polyglot Testing Matrix

Polytrix is a polyglot test runner and documentation generator. It aims to let you run sample code written in any language. It's especially useful if you want to run similar code samples in multiple languages, a project that has been ported to several languages, or API clients for the same service that are provided in several languages.

Polytrix was influenced by a number of polyglot projects, including [Travis-CI](travis-ci.org), [Docco](https://github.com/jashkenas/docco), [Slate](https://github.com/tripit/slate), and polyglot test-suites like the [JSON Schema Test Suite](https://github.com/json-schema/JSON-Schema-Test-Suite) and the [JSON-LD Test Suite](http://json-ld.org/test-suite/).

The user-experience was heavily influenced by [test-kitchen](http://kitchen.ci/). Polytrix aims to do for multi-language development of command-line applications what test-kitchen has done for multi-platform development of infrastructure.

## Installing Polytrix

Polytrix is distributed as a Ruby Gem. It should be installed using Bundler by adding this line to your Gemfile:

```shell
gem 'polytrix', '~> 0.1'
```

And then running `bundle install`.

It can also be installed without Bundler by running `gem install polytrix`.

## Getting Help

Polytrix is primarily intented to be run as a standalone utility, though it does have an API for integrating with RSpec or other Ruby-based test frameworks.

Note: You may need to prefix commands with `bundle exec` if you installed Polytrix using Bundler.

If you need a quick reminder of what the `polytrix` command gives you, then use the **help** subcommand:

```
$ bundle exec polytrix help
Commands:s
  polytrix bootstrap [(all|<REGEX>)] [opts] # Bootstraps the code samples for one or more tests
  polytrix code2doc [(all|<REGEX>)] [opts]  # Converts annotated code samples to Markdown or reStructuredText
  polytrix clean [(all|<REGEX>)] [opts]     # Removes test results for one or more tests
  polytrix clone [(all|<REGEX>)] [opts]     # Clones the code samples from git for one or more tests
  polytrix exec [(all|<REGEX>)] [opts]      # Executes code samples for one or more tests
  polytrix help [COMMAND]                   # Describe available commands or one specific command
  polytrix list [(all|<REGEX>)] [opts]      # List all tests
  polytrix test [all|<REGEX>)] [opts]       # Test one or more tests
  polytrix verify [(all|<REGEX>)] [opts]    # Verify the execution results of one or more tests
  polytrix version                          # Print Polytrix's version information
```

## The polytrix.yml file

The Polytrix test suites and the implementors that should be tested are defined in a polytrix.yml file.
A basic file looks like this:

```yaml
polytrix:
  implementors:
    ruby_samples:
      language: ruby
      bootstrap_cmd: bundle install
      exec_cmd: bundle exec ruby
      git:
        repo: https://github.com/polytrix/ruby_samples
    python_samples:
      language: python
      bootstrap_script: scripts/pip_install
      exec_script: scripts/pip_install
      git:
        repo: https://github.com/polytrix/python_samples
    java_samples:
      language: java
      # The default is to look for scripts/bootstrap and scripts/exec
      # or try to use the default bootstrap/exec behavior for the language
      git:
        repo: 'https://github.com/polytrix/java_samples'

  suites:
    katas:
      code_samples:
        hello_world:
          - validate:
              stdout: Hello, World!
        quine:
          - validate:
              quine_validator: true
    utilities:
      code_samples:
        word_count:
          - name: short text
            input: |
              I am a word count utility
            validate:
              stdout: 6 words
          - name: small file
            input_file: fixtures/small_file.txt
            validate:
              stdout: 10 words
          - name: large file
            input_file: fixtures/large_file.txt
            validate:
              stdout: 1000 words
```

### Defining Implementors

Polytrix tests scenarios across one or more implementors. The implementors may each be in a different
language, but you can also have multiple implementors for the same langauge. The structure used to define implementors within polytrix.yml is described below.

#### Implementor Object

Field Name | Type | Description
---|:---:|---
<a name="implementor_name"/>name | `string` | The name of the implementor. (*If omitted, this attribute’s value defaults to the key name associated with this object.*)
<a name="implementor_directory"/>directory | `string` | The location of the implementor project containing code samples.
<a name="implementor_language"/>language | `string` | The primary programming language of the code samples in this implementor.
<a name="implementor_git"/>git | [Git Object](#git_object) | Defines how to clone the project via Git.
<a name="implementor_scripts"/>scripts | [Scripts Object](#scripts_object) | Defines scripts to bootstrap, compile, and execute the samples.

#### Git Object
<a name="git_object"/>Field Name | Type | Description
---|:---:|---
<a name="git_repo"/>repo | `string` | **Required.** The git repo to clone.
<a name="git_branch"/>branch | `string` | The git branch to clone.
<a name="git_to"/>to | `string` | The local directory to clone into.

#### Scripts Object
<a name="scripts_object"/>Field Name | Type | Description
---|:---:|---
<a name="directory"/>directory | `directory` | The directory that contains the script files. **Default**: `scripts/`.
<a name="bootstrap_script"/>bootstrap_script | `file` | The file to execute to bootstrap the samples. **Default**: `bootstrap`
<a name="compile_script"/>compile_script | `file` | The file to execute to compile the samples. **Default**: `compile`
<a name="exec_script"/>exec_script | `file` | The file to use as an execute wrapper script for running samples. **Default**: `exec`
<a name="bootstrap_cmd"/>bootstrap_cmd | `string` | An inline script to execute instead of executing *bootstrap_file*.
<a name="compile_cmd"/>compile_cmd | `string` | An inline script to execute instead of executing *bootstrap_file*.
<a name="exec_cmd"/>exec_cmd | `string` | An inline script to use as an execution wrapper, instead of searching for a `exec` script.

#### Example Implementor Definition

```yaml
implementors:
  ruby_samples:
    directory: samples/ruby
    language: ruby
    git:
      repo: https://github.com/polytrix/ruby_samples
      branch: master
      to: samples/ruby
    scripts:
      bootstrap_cmd: bundle install
      exec_cmd: bundle exec ruby "$@"
```

### Attaching Code Samples

Polytrix tests are divided into suites, code samples, and scenarios. Each tuple (suite, code sample, scenario) is a test.

The structure used to define tests is:

#### Suite Object

Field Name | Type | Description
---|:---:|---
<a name="suite_name"/>name | `string` | The name of the suite. (*If omitted, this attribute’s value defaults to hash key associated with this object.*)
<a name="suite_input"/>input | `string` | The content to send to the code sample as standard input.
<a name="suite_input_file"/>input_file | `file` | Reads the specified file and sets *input*.
<a name="code_samples"/>code_samples | Hash of [Code Samples](#code_samples) | Defines the code samples to test

#### Code Sample Object

The code sample object determines which scenario to runwhich determines which code sample will be run. It can also
override the default values set in the Suite Object.

If the Scenario Object is a list, it will be automatically split into distinct but related scenarios. This is useful
for testing the same code sample with a variety of different input values.

Field Name | Type | Description
---|:---:|---
<a name="code_sample_name"/>name | `string` | The name of the suite. (*If omitted, this attribute’s value defaults to hash key associated with this object.*)
<a name="scenarios"/>language | List of [Scenario Objects](#scenario_object) | Defines the scenarios to test for the code sample. **Default**: An scenario named default with no input.


#### Scenario Object

Field Name | Type | Description
---|:---:|---
<a name="scenario_name"/>name | `string` | **Required.** The scenario name.
<a name="scenario_input"/>input | `string` | The content to send to the code sample as standard input.
<a name="scenario_input_file"/>input_file | `file` | Reads the specified file and sets *input*.
<a name="scenarios"/>language | Hash of [Scenario Objects](#scenario_object) | Defines the scenarios within the suite

#### Example Suite Definition

```yaml
  suites:
    katas:
      scenarios:
        hello_world:
          validate:
            stdout: Hello, World!
        quine:
          validate:
            quine_validator: true
    utilities:
      scenarios:
        word_count:
          - name: short text
            input: |
              I am a word count utility
            validate:
              stdout: 6 words
          - name: small file
            input_file: fixtures/small_file.txt
            validate:
              stdout: 10 words
          - name: large file
            input_file: fixtures/large_file.txt
            validate:
              stdout: 1000 words
```

## Plugins

TBD

## Custom Validators

TBD

## Usage

### Cloning implementors
### Bootstrapping implementors
### Executing scenarios
### Verifying scenario results
### Full test

```
