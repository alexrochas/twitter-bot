require 'twitter'
require 'octokit'
require 'pp'
require 'dotenv'

Dotenv.load

client = Octokit::Client.new(:login => 'alexrochas', :password => ENV['GITHUB_PASS'], per_page: 200)
# client.auto_paginate = true

repos = client
        .repos
        .reject {|repo| repo.private }

repo_sample = repos.sample

enhance_repo = lambda { |repo|
  {
    name: repo.name,
    url: repo.html_url,
    description: repo.description,
    languages: client.languages(repo.full_name)
  }
}

repo = enhance_repo.call(repo_sample)

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end

message = "Take a look at my repo #{repo[:name]} at (#{repo[:url]})
#{repo[:description]}, [#{repo[:languages].map{|l| l.first.to_s}.join(', ')}]\n
#github #awesomerepos"

puts message

client.update(message)
