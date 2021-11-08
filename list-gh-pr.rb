#!/usr/bin/ruby
#
# usage: bundle exec ruby list-gh-pr.rb
# lists recent open pull requests to non-fork repos from others
#
# Copyright (c) 2021 zunda <zundan at gmail.com>
# Published under MIT license
#
require 'netrc'
require 'faraday'
require 'json'

api_host = 'api.github.com'
github_user, github_token = Netrc.read[api_host]
raise RuntimeError, "Token for #{api_host} is not found in #{Netrc.default_path}." unless github_token

faraday_opts = {
  'User-agent' => 'list-gh-pr/0.0.0',
  'Accept' => "application/vnd.github.v3+json",
  'Authorization' => "token #{github_token}"
}

r = Faraday.get("https://#{api_host}/users/#{github_user}/repos",
  {sort: "updated", direction: "desc", per_page: 100},
  faraday_opts
)
raise RuntimeError, r.body unless r.status == 200
repos = JSON.parse(r.body).reject{|e| e.dig('fork')}.map{|e| e.dig('name')}

repos.each do |repo|
  r = Faraday.get("https://#{api_host}/repos/#{github_user}/#{repo}/pulls",
    {state: "open", sort: "updated", direction: "desc", per_page: 100},
    faraday_opts
  )
  raise RuntimeError, r.body unless r.status == 200
  pulls = JSON.parse(r.body).reject{|p| p.dig('user', 'login') == github_user}
  if pulls.empty?
    $stderr.print "."
  else
    puts
    pulls.each do |pull|
      puts "#{pull['html_url']}\t#{pull['title']}"
    end
  end
end
$stderr.puts
