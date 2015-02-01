# Atom : Cargo test runner

[![License](http://img.shields.io/badge/license-MIT-yellow.svg?style=flat)](https://github.com/nguyenchr/atom-cargo-test-runner/blob/master/LICENSE.md)

Runs [Cargo](https://crates.io/) tests from within Atom.

- `ctrl-alt-c` runs the current test file

- `ctrl-alt-shift-c` re-runs the last test selection 
  - even if you switched to another tab

This package is heavily based off [Mocha Test Runner](https://github.com/TabDigital/atom-mocha-test-runner)

### Requirements
[Rust](https://rust-lang.org) and [Cargo](https://crates.io/) must be installed.

### Usage

This plugin looks for the closest `cargo.toml` to the current file
It then runs cargo from this directory

### Settings

If you go to the settings pane, you can set the following values:

- `Cargo binary path`: path to the `cargo` executable (*defaults to `/usr/local/bin/cargo`*).
- `Show context information`: display extra information for troubleshooting (*defaults to `false`*)
- `Options`: append given options always to cargo binary  (*optional*)

### Help

I built this plugin while learning Rust. I'm sure there are a bunch of cool things that Cargo can do that I don't know about yet, if you can think of a cool feature, feel free to help out.

