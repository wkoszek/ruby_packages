#!/usr/bin/env ruby
# Copyright 2017 Wojciech Adam Koszek <wojciech@koszek.com>

require 'octokit'
require 'json'
require './mdserializer.rb'

include MdSerializer

GITHUB_TOKEN = ENV['GITHUB_TOKEN']
VER = ENV['RUBY_PKG_VERSION']
JOB = ENV['TRAVIS_JOB_ID']
TRAVIS_ENV_VARS = %w{
  TRAVIS_BUILD_DIR
  TRAVIS_BUILD_ID
  TRAVIS_BUILD_NUMBER
  TRAVIS_COMMIT_MESSAGE
  TRAVIS_JOB_ID
  TRAVIS_JOB_NUMBER
}
REPO_NAME = "wkoszek/ruby_packages"

def travis_get_info
  env_names = TRAVIS_ENV_VARS
  msg = "## Travis info\n\n"
  tab = MdSerializer::MdTable.new()
  tab.add_row([ "Environment variable", "Name" ])
  env_names.each do |en|
    tab.add_row([ MdSerializer::MdTt(en), ENV[en] ]);
  end
  return msg + tab.to_md
end

def make_travis_url(build_id)
  return "https://travis-ci.org/wkoszek/ruby_packages/builds/#{build_id}"
end

def make_rel_notes_body(url)
  msg = "## Wojciech's Ruby release"
  msg += "\n\n"

  tab = MdSerializer::MdTable.new()
  tab.add_row([ "Label", "Value" ])
  tab.add_row([
    "Release built time",
    Time.now.to_s
  ]);
  tab.add_row([
    "Source",
    MdSerializer::MdLink(url, url)
  ]);

  build_id = ENV['TRAVIS_BUILD_ID']
  travis_url = make_travis_url(build_id)
  tab.add_row([
    "Build log",
    MdSerializer::MdLink(travis_url, travis_url)
  ]);

  msg += tab.to_md + "\n\n"

  msg += "## Checksums\n\n"
  msg += '```' + "\n"
  msg += `openssl sha1 *.tar.gz *.deb 2>/dev/null`
  msg += '```' + "\n\n"

  msg += travis_get_info()
  msg += "\n\n"

  return msg
end

def usage
  STDERR.puts "make-release.rb <file> <tagname> <orig_url>\n"
  exit 64
end

def main
  if ARGV.length != 3
    usage()
  end
  asset_filename = ARGV[0]
  tag_name = ARGV[1]
  rel_url = ARGV[2]

  notes = make_rel_notes_body(rel_url)
  if asset_filename == "-sim"
    print notes, "\n"
    return
  end

  client = Octokit::Client.new(:access_token => GITHUB_TOKEN)
  user = client.user
  user.login

  releases = client.releases(REPO_NAME)

  rel = client.create_release(REPO_NAME, tag_name, {
    :name => "Ruby #{VER} package #{JOB}",
    :body => notes,
  })

  client.upload_asset(rel.url, asset_filename, {
    :content_type => "application/vnd.debian.binary-package"
  })
end

main
