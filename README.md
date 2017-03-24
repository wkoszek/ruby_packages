# Ruby packages built for Ubuntu

[![Build Status](https://travis-ci.org/wkoszek/ruby_packages.svg?branch=master)](https://travis-ci.org/wkoszek/ruby_packages)

This projects delivers scripts to build a Ruby release.
Resulting `.deb` package can be used on Ubuntu GNU/Linux.
Resulting artifacts are published in this repo, in a "Releases" tab.
Build is reproducible, and is done and published from [Travis-CI](https://travis-ci.org/)
Each release has information on where it came from and has links to the respective build log.

# How to use it

Just go to [releases](https://github.com/wkoszek/ruby_packages/releases), and pick the most up-to-date Ruby build.
Builds aren't removed, so you can lock yourself to a Ruby version, if you want.

**Example:**

```shell
wget https://github.com/wkoszek/ruby_packages/releases/download/v2_4_0_214300773/ruby_2.4.0-1_amd64.deb
dpkg -i ruby_2.4.0-1_amd64.deb
```

# How to reproduce

You can use this repo to ship your own Ruby versions from Travis-Ci.
For this, you must define two environment variables:

-  `GITHUB_TOKEN` holds a GitHub authentication token.
-  `RUBY_PKG_VERSION` holds a Ruby version in a `X.Y.Z` format.

The later is set for you in `.travis.yml`. The former set in Travis-CI web GUI or from its gem:

```shell
gem install travis
travis env set GITHUB_TOKEN your_token
```
