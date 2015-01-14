# Crosstest - the polyglot testing tool

Crosstest is a tool from running tests and other tasks across a set of related projects. It's a tool for polyglots - the tests and tasks can be written in any language, using any tool. Crosstest may be useful for:
- Testing a set of related open-source projects (e.g. a set of plugins for a framework)
- Teams working on microservices or other sets of small projects
- Testing tools, SDKs or API bindings that have been ported to several programming languages

Crosstest can be used as a tool to run unrelated tests in each project, but it can also be used to build a compliance suite for projects that
are expected to implement the same features, like an SDK that has been ported to multiple programming languages. In those cases corsstest can
be used to build a compatibility test suite across the projects, including reports that compare the working features and detected behavior.

Crosstest was influenced by a number of polyglot projects, including [Travis-CI](travis-ci.org), [Docco](https://github.com/jashkenas/docco), [Slate](https://github.com/tripit/slate), and polyglot test-suites like the [JSON Schema Test Suite](https://github.com/json-schema/JSON-Schema-Test-Suite) and the [JSON-LD Test Suite](http://json-ld.org/test-suite/).

A lot of the crosstest implementation was influenced by [test-kitchen](http://kitchen.ci/), because in many ways crosstest is attempting to do for cross-project testing what test-kitchen does for cross-platform testing.

## Installing Crosstest

Crosstest is distributed as a Ruby Gem. It is ideally installed using Bundler by adding this line to your Gemfile:

```shell
gem 'crosstest', '~> 0.1'
```

And then running `bundle install`.

It can also be installed without Bundler by running `gem install crosstest`.

**Note**: If installed with bundler it's best to always run `bundle exec crosstest ...` rather than just `crosstest ...`. The bundler documentation explains:

> In some cases, running executables without `bundle exec` may work, if the executable happens to be installed in your system and does not pull in any gems that conflict with your bundle.
>
> However, this is unreliable and is the source of considerable pain. Even if it looks like it works, it may not work in the future or on another machine.

## Defining a project set

You need to define a set of projects so crosstest can run tasks or tests across them. This is done with a `crosstest.yaml` file. The file defines the
name and location of each project, optionally including version control information.

Here's an example that defines projects named "ruby", "java" and "python":

```yaml
---
  projects:
    ruby:
      language: 'ruby'
      basedir: 'sdks/ruby'
      git:
        repo: 'https://github.com/crosstest/ruby_samples'
    java:
      language: 'java'
      basedir: 'sdks/java'
      git:
        repo: 'https://github.com/crosstest/java_samples'
    python:
      language: 'python'
      basedir: 'sdks/python'
      git:
        repo: 'https://github.com/crosstest/python_samples'
```

## Getting the projects

Crosstest needs to have a copy of the project before it can run any tasks or tests. If you already have the projects locally and configured
the `basedir` of each project to point to the existing location you can move on to the next step. If you don't have the projects locally but
configured the git repo then you can fetch them with the `crosstest clone` command.

```sh
$ bundle exec crosstest clone
-----> Starting Crosstest (v0.2.0)
       Cloning: git clone https://github.com/crosstest/ruby_samples -b master /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/ruby
       Executing git clone https://github.com/crosstest/ruby_samples -b master /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/ruby
       Cloning into '/Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/ruby'...
       Cloning: git clone https://github.com/crosstest/java_samples -b master /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java
       Executing git clone https://github.com/crosstest/java_samples -b master /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java
       Cloning into '/Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java'...
       Cloning: git clone https://github.com/crosstest/python_samples -b master /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/python
       Executing git clone https://github.com/crosstest/python_samples -b master /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/python
       Cloning into '/Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/python'...
-----> Crosstest is finished. (0m1.12s)
```

## Crosstasking

Crosstest needs to be able to run tasks in any of the projects before it can run tests. Crosstest uses [psychic](https://github.com/crosstest/psychic-runner), to run tasks. Psychic creates a uniform interface for running similar tasks in different projects, delegating to project specific task runners (like Rake, Make, npm run, or gradle) when necessary.

The first task you probably want to run is `bootstrap` in order to make sure the projects project is ready to test. Generally the `bootstrap` task will invoke a dependency manager like Bundler, npm, or pip.

```sh
$ bundle exec crosstest bootstrap
-----> Starting Crosstest (v0.2.0)
-----> Bootstrapping ruby
       Executing bundle install
       Resolving dependencies...
       Your bundle is complete!
       Use `bundle show [gemname]` to see where a bundled gem is installed.
-----> Bootstrapping java
       Executing mvn clean install
       :compileJava UP-TO-DATE
       :processResources UP-TO-DATE
       :classes UP-TO-DATE
       :jar
       :assemble
       :compileTestJava UP-TO-DATE
       :processTestResources UP-TO-DATE
       :testClasses UP-TO-DATE
       :test UP-TO-DATE
       :check UP-TO-DATE
       :build

       BUILD SUCCESSFUL

       Total time: 4.4 secs
```

### Custom tasks

There are a few default tasks like `bootstrap` that are built into crosstest (and psychic). The default tasks exist to match common test workflows (like the Travis-CI stages or Maven lifecycle), but you can also have crosstest invoke custom tasks.

So you could tell crosstest to invoke custom tasks like `documentation`, `metrics`, or `lint`:

```sh
$ bundle exec crosstest task lint
-----> Starting Crosstest (v0.2.0)
-----> Running task lint for ruby
       Executing bundle exec rubocop -D
       warning: parser/current is loading parser/ruby21, which recognizes
       warning: 2.1.5-compliant syntax, but you are running 2.1.4.
       Inspecting 2 files
       ..

       2 files inspected, no offenses detected
-----> Running task lint for java
       Executing gradle checkstyleMain
       :compileJava UP-TO-DATE
       :processResources UP-TO-DATE
       :classes UP-TO-DATE
       :checkstyleMain[ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/HelloWorld.java:0: Missing package-info.java file.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/HelloWorld.java:1: Line is longer than 100 characters (found 101).
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/HelloWorld.java:3: Missing a Javadoc comment.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:1: Missing a Javadoc comment.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:2:1: warning: '{' should be on the previous line.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:4:3: warning: '{' should be on the previous line.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:24: warning: 'for' construct must use '{}'s.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:24:8: 'for' is not followed by whitespace.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:24:30: warning: ')' is preceded with whitespace.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:26: warning: 'for' construct must use '{}'s.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:26:8: 'for' is not followed by whitespace.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:27:28: warning: '(' is followed by whitespace.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:27:54: warning: ')' is preceded with whitespace.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:28: warning: 'for' construct must use '{}'s.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:28:8: 'for' is not followed by whitespace.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:29:28: warning: '(' is followed by whitespace.
       [ant:checkstyle] /Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/src/main/java/Quine.java:29:33: warning: ')' is preceded with whitespace.
        FAILED

       FAILURE: Build failed with an exception.

       * What went wrong:
       Execution failed for task ':checkstyleMain'.
       > Checkstyle rule violations were found. See the report at: file:///Users/Thoughtworker/repos/rackspace/polytrix/samples/sdks/java/build/reports/checkstyle/main.xml

       * Try:
       Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.

       BUILD FAILED

       Total time: 4.904 secs
-----> Running task lint for python
       Executing ./scripts/lint.sh
       New python executable in crosstest_python/bin/python
       Installing setuptools, pip...done.
       katas/hello_world.py:2:22: W292 no newline at end of file
       katas/quine.py:2:8: E228 missing whitespace around modulo operator
-----> Crosstest is finished. (0m8.49s)
```

This is equivalent to running `psychic task lint` in each directory. See [psychic](https://github.com/crosstest/psychic-runner) for more details about how psychic decides what command to invoke for any given task.

## Crosstesting



### Built-in tasks




Now that the projects are defined you need to fetch the code before you can run any tasks or tests on the projects. If you already have

Once hte set of
In order to be able run tests in any project we first need to be able to run tasks in any project.

## Features

- Validate sample code by running it through a series of stages:
  * Clone: Fetch existing code samples from other git repos
  * Detect: Match code samples for specific implementors to shared test scenarios
  * Bootstrap: Install runtime dependencies for each implementor
  * Exec: Invoke each test sample and capture the results (with built-in or custom spies)
  * Validate: Ensure execution results (and data captured by spies) matches expectations
- Use spies to capture data on how each code sample behaves when executed
- Generate reports or documentation:
  - A feature matrix comparing several implementations
  - A test dashboard with detailed results and captured data for each code sample that was tested
  - Convert code samples to documentation
  - Generate to-do lists for pending features
  - Custom reports or documentation generation for anything else

## Usage

### Setup

The Crosstest test suites are defined by `crosstest.yml`. This file defines the implementors you want to test and the test scenarios that they share. A simple Crosstest setup looks like this:

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

Crosstest provides a CLI for driving tests, quickly viewing test results, or to generate test reports.

In order to see all available commands, simply run `bundle exec crosstest`:

```bash
$ bundle exec crosstest

  Commands:
  crosstest bootstrap [INSTANCE|REGEXP|all]  # Change scenario state to bootstraped. Running bootstrap scripts for the implementor
  crosstest clone [INSTANCE|REGEXP|all]      # Change scenario state to cloned. Clone the code sample from git
  crosstest destroy [INSTANCE|REGEXP|all]    # Change scenario state to destroyed. Delete all information for one or more scenarios
  crosstest detect [INSTANCE|REGEXP|all]     # Find sample code that matches a test scenario. Attempts to locate a code sample with a filename that the test scenario name.
  crosstest exec [INSTANCE|REGEXP|all]       # Change instance state to executed. Execute the code sample and capture the results.
  crosstest help [COMMAND]                   # Describe available commands or one specific command
  crosstest list [INSTANCE|REGEXP|all]       # Lists one or more scenarios
  crosstest report                           # Generate reports
  crosstest show [INSTANCE|REGEXP|all]       # Show detailed status for one or more scenarios
  crosstest test [INSTANCE|REGEXP|all]       # Test (clone, bootstrap, exec, and verify) one or more scenarios
  crosstest verify [INSTANCE|REGEXP|all]     # Change instance state to verified. Assert that the captured results match the expectations for the scenario.
  crosstest version                          # Print Crosstest's version information
```

The `INSTANCE` or `REGEXP` used in commands is matched against `Test ID`, which is an unique ID derived from the suite, scenario, and implementor names for a test. You can see the `Test ID`s via `crosstest show`.

#### List and Show

The command `crosstest list [INSTANCE|REGEXP|all]` or `crosstest show [INSTANCE|REGEXP|all]` can be used to give you an overview (list) or detailed information (show) about all tests or a subset of tests.

Initially the tests will have a status of "<Not Found>", but the status will change and details will become available as you run the commands below.

#### Cloning

The command `crosstest clone [INSTANCE|REGEXP|all]` will fetch code samples for an implementor from a git repo. This step is skipped if no git repo is specified for the implementor, or if it already appears to be cloned.

#### Bootstrapping

The command `crosstest clone [INSTANCE|REGEXP|all]` will "bootstrap" the implementors.

Bootstrapping ensures the implementor has the resources it needs to run samples, especially third-party libraries. Bootstrapping behavior is controlled by:

- The presence of a [bootstrap script](http://wynnnetherland.com/linked/2013012801/bootstrapping-consistency) in `script/bootstrap`
- A bootstrap command defined within the implementor in the `crosstest.yml`
- Default behavior for the implementors language

#### Detecting

The command `crosstest clone [INSTANCE|REGEXP|all]` will search each implementor for code samples that correspond with test scenarios.

Crosstest searches for samples by:

- Checking the implementor definition (in `crosstest.yml`) a static mapping of test scenarios to files.
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

The command `crosstest exec [INSTANCE|REGEXP|all]` will execute a code sample while capturing data via spies.

If the code sample is executable (e.g. many Bash, Ruby, or Python scripts) then Crosstest can execute it directly. If it is not direclty executable you can create a `script/wrapper`. Crosstest will execute the wrapper script with the first argument set to the path to the code sample. You can use this to defer to `bundle exec`, `node`, `java`, or any other program or script necessary to run the code sample.

Crosstest has a built-in spy to capture the processes exit status, stdout, and stderr. You can register custom spies to capture additional information. For example, a [Pacto](https://github.com/thoughtworks/pacto) spy has been used to capture HTTP requests that are made by code samples and match them to known services defined via [Swagger](http://swagger.io/).

TODO: Documentation on custom spies.

Successfully completing this stage will set a test's status to `Executed`.

#### Validating

The command `crosstest verify [INSTANCE|REGEXP|all]` will check the captured data from executing a code sample against the validators for that test scenario.

The validators are shared across all implementors, acting as a compliance test suite. A default validator is used if a test does not have any specific validators. A scenario can have more than one validator.

TODO: Documentation on writing validators.

This stage will set the test's status to `Partially Verified (n of m)` or `Fully Verified (n of n)`, where `n` is the number of validators that succeeded and `m` is the number of validators registered for the test scenario.

#### Cleaning

The command `crosstest destroy [INSTANCE|REGEXP|all]` clears out the saved test status and captured data.

This will set the status back to `<Not Found>`.

#### Testing

The command `crosstest test [INSTANCE|REGEXP|all]` combines the commands above into a single command. It runs in order:

destroy->detect->exec->verify

### Reports

#### Dashboard

The command `crosstest report dashboard` will generate an HTML feature matrix where each result is a link to more information about the test execution.

#### Code2doc

The command `crosstest report code2doc [INSTANCE|REGEXP|all]` will convert annotated code samples to documentation. It is similar to projects like [docco](https://github.com/jashkenas/docco), except that it generates Markdown or reStructuredText rather than fully-styled HTML. The idea is that you can more easily drop these files into static site generators like [middlemanapp](http://middlemanapp.com/), documentation tools like [slate](https://github.com/tripit/slate), or services like [viewdocs](http://progrium.viewdocs.io/viewdocs) or [readthedocs](https://readthedocs.org/), which already handle styling and syntax highlighting.

## Solo mode

TODO: Crosstest' experimental solo mode for running samples w/out a `crosstest.yml`.
