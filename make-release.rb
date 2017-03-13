#!/usr/bin/env ruby
# Copyright 2017 Wojciech Adam Koszek <wojciech@koszek.com>

require 'octokit'
require 'json'

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
  env_names.each do |en|
    msg += "#{en}\t#{ENV[en]}\n"
  end
  return msg
end

def make_rel_notes_body
  url = "https://github.com/ruby/ruby/archive/"

  msg = "## Wojciech's Ruby release"
  msg += "\n"
  msg += "\n"
  msg += "Release built at #{Time.now} at Travis CI. Ruby version was \`#{VER}\`"
  msg += "\n"
  msg += "\n"
  msg += "The sources for the release came from [#{url}](#{url})."
  msg += "\n"
  msg += "\n"
  msg += `openssl sha1 *.tar.gz *.deb 2>/dev/null`
  msg += "\n"
  msg += "\n"
  msg += travis_get_info()
  msg += "\n"
  msg += "\n"
  return msg
end

def usage
  STDERR.puts "make-release.rb <file>\n"
  exit 64
end

def main
  if ARGV.length != 2
    usage()
  end
  asset_filename = ARGV[0]
  tag_name = ARGV[1]

  client = Octokit::Client.new(:access_token => GITHUB_TOKEN)
  user = client.user
  user.login

  releases = client.releases(REPO_NAME)

  rel = client.create_release(REPO_NAME, "master", {
    :name => "Ruby #{VER} package #{JOB}",
    :body => make_rel_notes_body(),
  })

  client.upload_asset(rel.url, asset_filename, {
    :content_type => "application/vnd.debian.binary-package"
  })
end

main
