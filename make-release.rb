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
    msg += "\`#{en}\`\t#{ENV[en]}\n"
  end
  return msg
end

def make_travis_url(build_id)
  return "https://travis-ci.org/wkoszek/ruby_packages/builds/#{build_id}"
end

def make_rel_notes_body(url)
  msg = "## Wojciech's Ruby release"
  msg += "\n\n"

  msg += "Release built at \`#{Time.now}\` at Travis CI. Ruby version was \`#{VER}\`"
  msg += "\n\n"

  msg += "Source: [#{url}](#{url})\n\n"
  msg += "\n\n"

  build_id = ENV['TRAVIS_BUILD_ID']
  travis_url = make_travis_url(build_id)
  msg += "Build log: [#{travis_url}](#{travis_url})\n"
  msg += "\n\n"

  msg += "The sources for the release came from [#{url}](#{url})."
  msg += "\n\n"

  msg += '```\n'
  msg += `openssl sha1 *.tar.gz *.deb 2>/dev/null`
  msg += '```\n'

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

  client = Octokit::Client.new(:access_token => GITHUB_TOKEN)
  user = client.user
  user.login

  releases = client.releases(REPO_NAME)

  rel = client.create_release(REPO_NAME, tag_name, {
    :name => "Ruby #{VER} package #{JOB}",
    :body => make_rel_notes_body(rel_url),
  })

  client.upload_asset(rel.url, asset_filename, {
    :content_type => "application/vnd.debian.binary-package"
  })
end

main
