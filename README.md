# Polytrix - the Polyglot Testing Matrix

Polytrix is a tool for testing and generating documentation from sample code. It's a polyglot tool, so you can use it for samples written in any language. It's especially targeted for compliance testing, where you have similar code samples written in multiple languages and you want to generate a feature matrix or verify that each implementation has similar behavior.

If you find projects like [Slate](https://github.com/tripit/slate) interesting but want ways to test the code or integrate with other documentation toolsets, then Polytrix might be a good fit.

# Installation


Polytrix is distributed as a Ruby Gem. The best way to install is with [Bundler](http://bundler.io/) by adding this to your Gemfile and running `bundle install`:
```
gem 'polytrix'
```

You may also be able to install it as a system-wide gem:
```bash
gem install polytrix
```

The commands below all assume you used bundler. If you installed the gem directly, don't use `bundle exec` on the commands.

# Features

## Documentation-only

### code2doc

The simplest thing you can do with Polytrix is have it convert code samples into documentation written in Markdown or reStructuredText. These files can easily be dropped into a static site generator like [Middleman](http://middlemanapp.com/), [Jekyll](http://jekyllrb.com/), or [DocPad](http://docpad.org/), documentation tools like [SphinxDoc](http://sphinx-doc.org/), or simply commit them to git to serve with services [GitHub Pages](https://pages.github.com/) or [viewdocs.io](http://progrium.viewdocs.io/viewdocs). All of those tools support syntax highlighting and custom layouts.

The result of using these tools is similar to using [Docco](https://github.com/jashkenas/docco)with the linear layout, except that it instead of trying to generate the final HTML like docco it leaves that for one of the tools above that supports Markdown or reStructuredText. There isn't any support for something like Docco's parallel layout, but [Slate](https://github.com/tripit/slate) has shown that you creating parallel layouts from Markdown using JavaScript and CSS is possible.

In order to turn code into documentation you just run the `polytrix code2doc` command.

```bash
$ bundle exec polytrix help code2doc
Usage:
  polytrix code2doc FILES

Options:
  [--target-dir=TARGET_DIR]
                             # Default: docs
  [--lang=LANG]              # Source language (auto-detected if not specified)
                             # Possible values: bash, c, coffee-script, cpp, csharp, css, html, java, js, lua, php, python, rb, scala, scheme, xml
  [--format=FORMAT]
                             # Default: md
                             # Possible values: md, rst

$ bundle exec polytrix code2doc samples/sdks/java/challenges/*.java --target-dir=docs/samples/code2doc/java
polytrix:code2doc  Converting samples/sdks/java/challenges/HelloWorld.java to docs/samples/code2doc/java/HelloWorld.md
polytrix:code2doc  Converting samples/sdks/java/challenges/Quine.java to docs/samples/code2doc/java/Quine.md
```

That converts [HelloWorld.java](https://github.com/rackerlabs/polytrix/blob/master/samples/sdks/java/challenges/HelloWorld.java) to [HelloWorld.md](https://github.com/rackerlabs/polytrix/blob/master/docs/samples/code2doc/java/HelloWorld.md).

### snippetize

Coming soon! Generate a Markdown or reStructuredText file containing several short snippets extracted from a files containing the full source.

## Execution-only

### bootstrap

If your sample code has third-party dependencies, you'll need to make sure they are installed before running any samples. Polytrix provides a bootstrap action that installs third party dependencies.

You can run it by pointing to the directories that hold the samples:
```bash
$ bundle exec polytrix bootstrap samples/sdks/java samples/sdks/ruby samples/sdks/python
```

If you've already [defined implementors][#defining-an-implementor] you can run without options to bootstrap all of them, or by passing a name instead of a directory:
```bash
$ bundle exec polytrix bootstrap
$ bundle exec polytrix bootstrap java ruby python
```

Polytrix currently follows the [scripts/bootstrap convention](http://wynnnetherland.com/linked/2013012801/bootstrapping-consistency) by looking for a script/bootstrap (Linux) or script/bootstrap.ps1 (Windows) within the base directory of the implementor. In the future, Polytrix may provide default behavior similar to [Travis-CI](https://travis-ci.org/), automatically detecting popular dependency management tools like Bundler or npm.

### exec

If you're going to convert code samples to documentation, you probably want to make sure they're *working* samples. At a minimum, you should be able to execute them.

Polytrix provides you with a simple interface for runner code samples in any language. You just run `polytrix exec [FILEs]`, where the files are the sample code you want to run. Polytrix will figure out how to run each sample. You can also tell it to run it through code2doc if the execution is successful.

```bash
$ bundle exec polytrix exec --config samples/polytrix.rb samples/sdks/java/challenges/HelloWorld.java samples/sdks/python/challenges/hello_world.py samples/sdks/ruby/challenges/hello_world.rb
polytrix:exec  Running samples/sdks/java/challenges/HelloWorld.java...
polytrix:execute  . tmp/helloworld_vars.sh && scripts/wrapper ./challenges/HelloWorld.java
:compileJava
:processResources UP-TO-DATE
:classes
:jar
:assemble

BUILD SUCCESSFUL

Total time: 4.942 secs
Hello, world!
polytrix:exec[HelloWorld]  Finished with exec code: 0
polytrix:exec  Running samples/sdks/python/challenges/hello_world.py...
polytrix:execute  . tmp/hello_world_vars.sh && scripts/wrapper ./challenges/hello_world.py
Hello, world!
polytrix:exec[hello_world]  Finished with exec code: 0
polytrix:exec  Running samples/sdks/ruby/challenges/hello_world.rb...
polytrix:execute  . tmp/hello_world_vars.sh && ./challenges/hello_world.rb
Hello, world!
polytrix:exec[hello_world]  Finished with exec code: 0
```

Polytrix provides an polyglot runner so you can just point at a sample source and it will run it.

Notice that polytrix ran the ruby script directly:
```shell
./challenges/hello_world.rb
```

but it decided to use a wrapper script to run the python and Java code:
```shell
scripts/wrapper ./challenges/HelloWorld.java
scripts/wrapper ./challenges/hello_world.py
```

Polytrix will detect and use wrapper scripts that let you handle everything from compiling java code to using bundler with Ruby or virtualenv with Python.

See [defining an implementor][#defining-an-implementor] to see how to configure wrapper scripts.

## Compatibility testing

It's nice to know you can run the sample code successfully, but Polytrix also let's you check it does that the code has the expected result.

For example, we may want to test that the "Hello World" code samples print "Hello, world!", while the [Quine](http://en.wikipedia.org/wiki/Quine_(computing)) code samples produce a copy of their own source code.

### Polytrix configuration

Polytrix will look for a configuration file named `polytrix.rb`. You can use this to tell Polytrix which implementors it needs to test, and to override the location of the test manifest (see below) or any other default settings via a `Polytrix.configure` block:

```ruby
require 'polytrix'

basedir = File.expand_path('..', __FILE__)

Polytrix.configure do |polytrix|
  Dir["#{basedir}/sdks/*"].each do |sdk|
    name = File.basename(sdk)
    polytrix.implementor name: name, basedir: sdk
  end
end
```

If you only pass a single parameter to `polytrix.implementor`, Polytrix will assume that is the basedir, and will look for a `polytrix.yml` file in that directory with the rest of the settings for the implementor.

### Test Manifest

Polytrix will look for a file named `polytrix_tests.yml` that define the test scenarios you want to run and any environment variables Polytrix should setup before running them. Here's a sample:

```yaml
---
  global_env:                          # global_env defines input available for all scenarios
    LOCALE: <%= ENV['LANG'] %>         # templating is allowed
  suites:
    Katas:                             # "Katas" is the name of the first test suite
      env:                             # Unlike global_env, these variables are only for the Katas suite
        COLOR: green
      samples:                         # Test scenarios within Katas
        - hello world
        - quine
```

### test

Now that Polytrix is configured and the test manifest is defined, you can run tests and Polytrix will find the examples in each SDK. Polytrix does this by looking for code samples with file names that loosly match the sceanrio name. See [finding samples](#finding-samples) for more info about how Polytrix searches.

Polytrix does echo program output to stdout by default:
```
$ bundle exec polytrix test
I, [2014-06-30T19:05:14.054828 #65692]  INFO -- : polytrix:test Testing with rspec options: --color -f documentation -f Polytrix::RSpec::YAMLReport -o reports/test_report0.yaml

Katas
  hello world
    custom (PENDING: Feature hello world is not implemented)
polytrix:execute  . tmp/hello_world_vars.sh && scripts/wrapper ./challenges/HelloWorld.java
Hello, world!
    java
polytrix:execute  . tmp/hello_world_vars.sh && scripts/wrapper ./challenges/hello_world.py
Hello, world!
    python
polytrix:execute  . tmp/hello_world_vars.sh && ./challenges/hello_world.rb
Hello, world!
    ruby
  quine
    custom (PENDING: Feature quine is not implemented)
polytrix:execute  . tmp/quine_vars.sh && scripts/wrapper ./challenges/Quine.java
public class Quine
{
  public static void main(String[] args)
  {
    char q = 34;      // Quotation mark character
    String[] l = {    // Array of source code
    "public class Quine",
    "{",
    "  public static void main(String[] args)",
    "  {",
    "    char q = 34;      // Quotation mark character",
    "    String[] l = {    // Array of source code",
    "    ",
    "    };",
    "    for(int i = 0; i < 6; i++ )          // Print opening code",
    "        System.out.println(l[i]);",
    "    for(int i = 0; i < l.length; i++)    // Print string array",
    "        System.out.println( l[6] + q + l[i] + q + ',' );",
    "    for(int i = 7; i < l.length; i++)    // Print this code",
    "        System.out.println( l[i] );",
    "  }",
    "}",
    };
    for(int i = 0; i < 6; i++ )          // Print opening code
        System.out.println(l[i]);
    for(int i = 0; i < l.length; i++)    // Print string array
        System.out.println( l[6] + q + l[i] + q + ',' );
    for(int i = 7; i < l.length; i++)    // Print this code
        System.out.println( l[i] );
  }
}
    java
polytrix:execute  . tmp/quine_vars.sh && scripts/wrapper ./challenges/quine.py
s = 's = %r\nprint(s%%s)'
print(s%s)
    python
    ruby (PENDING: Feature quine is not implemented)

Pending:
  Katas hello world custom
    # Feature hello world is not implemented
    # /Users/Thoughtworker/repos/rackspace/polytrix/lib/polytrix/rspec.rb:22
  Katas quine custom
    # Feature quine is not implemented
    # /Users/Thoughtworker/repos/rackspace/polytrix/lib/polytrix/rspec.rb:22
  Katas quine ruby
    # Feature quine is not implemented
    # /Users/Thoughtworker/repos/rackspace/polytrix/lib/polytrix/rspec.rb:22

Finished in 0.40397 seconds
8 examples, 0 failures, 3 pending
I, [2014-06-30T19:05:14.467904 #65692]  INFO -- : polytrix:test Test execution completed
```

### Validating test samples

You can define validation callbacks that make sure each sample matches their expectations. This checks that the hello world and quine samples have the expected output:

```ruby
Polytrix.validate suite: 'Katas', sample: 'hello world' do |challenge|
  expect(challenge.result.stdout).to eq "Hello, world!\n"
end

Polytrix.validate suite: 'Katas', sample: 'quine' do |challenge|
  expect(challenge.result.stdout).to eq(challenge.source)
end
```

The block does the actual validation, while the arguments define the scope where the validation applies. If you omit the scope the validation will apply to all scenarios:

```
Polytrix.validate do |challenge|
  expect(challenge.result.exitstatus).to eq(0)
  expect(challenge.result.stderr).to be_empty
  expect(challenge.result.stdout).to end_with "\n"
end
```

### Plugins

Polytrix provides a built-in support for verifying the `stdout`, `stderr` and `exitstatus` after running a code sample, but it would be pretty limited if that was all you can do. Polytrix has a plugin system for more advanced validation, like using [Pacto](https://github.com/thoughtworks/pacto) to intercept and validate the usage of RESTful services.



# Usage preview

Polytrix is currently run via rspec. You can create a script that looks like this and run it with rspec:

```ruby
require 'polytrix/rspec'

Polytrix.implementors = Dir['sdks/*'].map{ |sdk|
  name = File.basename(sdk)
  Polytrix::Implementor.new :name => name
}

Polytrix.load_manifest 'polytrix_tests.yml'
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

You can use any RSpec formatter with Polytrix, since Polytrix is based on RSpec.

There are also some Polytrix specific documentation and report generators. You can generate:
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
