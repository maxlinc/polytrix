# Polytrix - the Polyglot Testing Matrix

Polytrix is a polyglot test runner and documentation generator. It aims to let you run sample code written in any language. It's especially useful if you want to run similar code samples in multiple languages, a project that has been ported to several languages, or API clients for the same service that are provided in several languages.

Polytrix was influenced by a number of polyglot projects, including [Travis-CI](travis-ci.org), [Docco](https://github.com/jashkenas/docco), [Slate](https://github.com/tripit/slate), and polyglot test-suites like the [JSON Schema Test Suite](https://github.com/json-schema/JSON-Schema-Test-Suite) and the [JSON-LD Test Suite](http://json-ld.org/test-suite/).

A lot of Polytrix was influenced by and based on [test-kitchen](http://kitchen.ci/). Polytrix is attempting to do for multi-language testing of code samples what test-kitchen does for multi-platform testing of infrastructure code.

## Features

- Validate sample code by running it through a series of stages:
  *  Clone: Fetch existing code samples from other git repos
  * Detect: Match code samples for specific implementors to shared test scenarios
  * Bootstrap: Install runtime dependencies for each implementor
  * Exec: Invoke each test sample and capture the results (with built-in or custom spies)
  * Validate: Ensure execution results (and data captured by spies) matches expectations
- Generate reports or documentation:
  - A feature matrix comparing several implementations
  - Detailed test reports showing validation results and data captured by spies
  - Custom reports from custom spies
  - Convert code samples to documentation
  - Inject code samples and/or captured execution data into documentation templates
  - Generate to-do lists for pending features

## Installing Polytrix

Polytrix is distributed as a Ruby Gem. It is ideally installed using Bundler by adding this line to your Gemfile:

```shell
gem 'polytrix', '~> 0.1'
```

And then running `bundle install`.

It can also be installed without Bundler by running `gem install polytrix`.

**Note**: If installed with bundler it's best to always run `bundle exec polytrix ...` rather than just `polytrix ...`. The bundler documentation explains:

> In some cases, running executables without `bundle exec` may work, if the executable happens to be installed in your system and does not pull in any gems that conflict with your bundle.
>
> However, this is unreliable and is the source of considerable pain. Even if it looks like it works, it may not work in the future or on another machine.

## Usage

### Setup

The Polytrix test suites are defined by `polytrix.yml`. This file defines the implementors you want to test and the test scenarios that they share. A simple Polytrix setup looks like this:

```yaml
---
  implementors:
    ruby_samples:
      language: 'ruby'
      basedir: 'sdks/ruby'
    java_samples:
      language: 'java'
      basedir: 'sdks/java'
    python_samples:
      language: 'python'
      basedir: 'sdks/python'

  global_env:                          # global_env defines input available for all scenarios
    LOCALE: <%= ENV['LANG'] %>         # templating is allowed
  suites:
    Katas:                             # "Katas" is the name of the first test suite
      samples:                         # Test scenarios within Katas
        - hello world
        - quine
    Environment:
      env:                             # Unlike global_env, these variables are only for the Katas suite
        COLOR: red
      samples:
        - echo_color
```

The `implementors` defines the projects you want to test, and `suites` defines the test scenarios.

### CLI - Testing

Polytrix provides a CLI for driving tests, quickly viewing test results, or to generate test reports.

In order to see all available commands, simply run `bundle exec polytrix`:

```bash
$ bundle exec polytrix

  Commands:
  polytrix bootstrap [INSTANCE|REGEXP|all]  # Change scenario state to bootstraped. Running bootstrap scripts for the implementor
  polytrix clone [INSTANCE|REGEXP|all]      # Change scenario state to cloned. Clone the code sample from git
  polytrix destroy [INSTANCE|REGEXP|all]    # Change scenario state to destroyed. Delete all information for one or more scenarios
  polytrix detect [INSTANCE|REGEXP|all]     # Find sample code that matches a test scenario. Attempts to locate a code sample with a filename that the test scenario name.
  polytrix exec [INSTANCE|REGEXP|all]       # Change instance state to executed. Execute the code sample and capture the results.
  polytrix help [COMMAND]                   # Describe available commands or one specific command
  polytrix list [INSTANCE|REGEXP|all]       # Lists one or more scenarios
  polytrix report                           # Generate reports
  polytrix show [INSTANCE|REGEXP|all]       # Show detailed status for one or more scenarios
  polytrix test [INSTANCE|REGEXP|all]       # Test (clone, bootstrap, exec, and verify) one or more scenarios
  polytrix verify [INSTANCE|REGEXP|all]     # Change instance state to verified. Assert that the captured results match the expectations for the scenario.
  polytrix version                          # Print Polytrix's version information
```

The `INSTANCE` or `REGEXP` used in commands is matched against `Test ID`, which is an unique ID derived from the suite, scenario, and implementor names for a test. You can see the `Test ID`s via `polytrix show`.

#### List and Show

The command `polytrix list [INSTANCE|REGEXP|all]` or `polytrix show [INSTANCE|REGEXP|all]` can be used to give you an overview (list) or detailed information (show) about all tests or a subset of tests.

Initially the tests will have a status of "<Not Found>", but the status will change and details will become available as you run the commands below.

#### Cloning

The command `polytrix clone [INSTANCE|REGEXP|all]` will fetch code samples for an implementor from a git repo. This step is skipped if no git repo is specified for the implementor, or if it already appears to be cloned.

#### Bootstrapping

The command `polytrix clone [INSTANCE|REGEXP|all]` will "bootstrap" the implementors.

Bootstrapping ensures the implementor has the resources it needs to run samples, especially third-party libraries. Bootstrapping behavior is controlled by:

- The presence of a [bootstrap script](http://wynnnetherland.com/linked/2013012801/bootstrapping-consistency) in `script/bootstrap`
- A bootstrap command defined within the implementor in the `polytrix.yml`
- Default behavior for the implementors language

#### Detecting

The command `polytrix clone [INSTANCE|REGEXP|all]` will search each implementor for code samples that correspond with test scenarios.

Polytrix searches for samples by:

- Checking the implementor definition (in `polytrix.yml`) a static mapping of test scenarios to files.
- Searching files matching the scenario name, using a rather lax search pattern
  - Search for a partial name match
  - Case-insensitive
  - Ignore ' ', '_', '-' and '.'
  - Do not search files or directories that are .gitignore'd.

This search pattern achieves a good hit rate while still letting implementors follow language or pattern conventions. For example, if the scenario is called "create server", the following file names will all match:

- src/java/com/foo/bar/CreateServer.java
- lib/foo/bar/create_server.rb
- samples/04-create-server.go

In order to avoid matching compiled files with similar names (like `CreateServer.class` or `create_server.pyc`) make sure they are gitignore'd.

Successfully completing this stage will set a test's status to `Sample Found`.

#### Executing

The command `polytrix exec [INSTANCE|REGEXP|all]` will execute a code sample while capturing data via spies.

If the code sample is executable (e.g. many Bash, Ruby, or Python scripts) then Polytrix can execute it directly. If it is not direclty executable you can create a `script/wrapper`. Polytrix will execute the wrapper script with the first argument set to the path to the code sample. You can use this to defer to `bundle exec`, `node`, `java`, or any other program or script necessary to run the code sample.

Polytrix has a built-in spy to capture the processes exit status, stdout, and stderr. You can register custom spies to capture additional information. For example, a [Pacto](https://github.com/thoughtworks/pacto) spy has been used to capture HTTP requests that are made by code samples and match them to known services defined via [Swagger](http://swagger.io/).

TODO: Documentation on custom spies.

Successfully completing this stage will set a test's status to `Executed`.

#### Validating

The command `polytrix verify [INSTANCE|REGEXP|all]` will check the captured data from executing a code sample against the validators for that test scenario.

The validators are shared across all implementors, acting as a compliance test suite. A default validator is used if a test does not have any specific validators. A scenario can have more than one validator.

TODO: Documentation on writing validators.

This stage will set the test's status to `Partially Verified (n of m)` or `Fully Verified (n of n)`, where `n` is the number of validators that succeeded and `m` is the number of validators registered for the test scenario.

#### Cleaning

The command `polytrix destroy [INSTANCE|REGEXP|all]` clears out the saved test status and captured data.

This will set the status back to `<Not Found>`.

#### Testing

The command `polytrix test [INSTANCE|REGEXP|all]` combines the commands above into a single command. It runs in order:

destroy->detect->exec->verify

### Reports

#### Dashboard

The command `polytrix report dashboard` will generate an HTML feature matrix where each result is a link to more information about the test execution.

#### Code2doc

The command `polytrix report code2doc [INSTANCE|REGEXP|all]` will convert annotated code samples to documentation. It is similar to projects like [docco](https://github.com/jashkenas/docco), except that it generates Markdown or reStructuredText rather than fully-styled HTML. The idea is that you can more easily drop these files into static site generators like [middlemanapp](http://middlemanapp.com/), documentation tools like [slate](https://github.com/tripit/slate), or services like [viewdocs](http://progrium.viewdocs.io/viewdocs) or [readthedocs](https://readthedocs.org/), which already handle styling and syntax highlighting.

## Solo mode

TODO: Polytrix' experimental solo mode for running samples w/out a `polytrix.yml`.
