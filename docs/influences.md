# Influences

This project was influenced by many other projects. The following projects are worth checking out, either as alternatives you might want to use instead of Crosstest, or to understand the domain better before contributing.

# Polyglot Testing

## Travis-CI

I do not know of any project that is as far along as Travis in terms of making it easy to test projects in most common languages. Currently this project is inspired by Travis, but in the future I hope to re-use Travis components and contribute back to the Travis community.

The most important Travis components for Polyglot testing are:
- [travis-cookbooks](https://github.com/travis-ci/travis-cookbooks) and [travis-images](https://github.com/travis-ci/travis-images) - create environments that are setup for testing any popular language
- [https://github.com/travis-ci/travis-build](travis-build) - creates scripts that handle setting up the environment for a given platform (Linux, OSX, Windows) and follow language conventions for dependency management and compilation.

## JSON-LD Test Suite and EARL Report

I've seen several compliance test suites, but the [JSON-LD suite](http://json-ld.org/test-suite/) is one of my favorites, including the [earl-report](https://github.com/gkellogg/earl-report) gem it uses to create reports.

The main difference between Crosstest and JSON-LD's test suite (and similar compliance tests for other projects) is that JSON-LD is data-driven and Crosstest is driven by sample code. The JSON-LD approach is good for standards about a data format like JSON-LD, while Crosstest is more for testing the functional completeness of similar SDKs.

## Codecademy

Codecademy's [Course Creation](http://www.codecademy.com/docs/creation) documentation explains how they test code samples written in different languages. You can think of Crosstest as serving a similar function to Codecademy's [Submission Tests](http://www.codecademy.com/docs/submission_tests), with two important differences:

- Crosstest aims for a single submission test for all languages: so could share a "Hello, world!" submission correctness test for Ruby, Java, and PHP.
- Crosstest is being used for automated test suites where the code submissions are pre-written and repeatedly tested, though creating a course with Crosstest may be possible.

This of course has some limitations. Since Crosstest is polyglot, we generally test only the effect of running the sample and not the syntax. Crosstest is not suitable for testing each variation when [there's more than one way to do it](http://en.wikipedia.org/wiki/There's_more_than_one_way_to_do_it), but you can use it to test that at least one way is possible.
