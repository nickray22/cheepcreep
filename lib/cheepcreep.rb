require "cheepcreep/version"
require "cheepcreep/init_db"
require "httparty"
require "pry"

module Cheepcreep
  class GithubUser < ActiveRecord::Base
  end
end

class Github
  include HTTParty
  base_uri 'https://api.github.com'
  # basic_auth ENV['apitestfun'], ENV['ironyard1']

  def initialize(user = 'apitestfun', pass = 'ironyard1')
    @auth = {:username => user, :password => pass}
  end

  def get_followers(username, options = {})
    options.merge!({:basic_auth => @auth})
    resp = self.class.get("/users/#{username}/followers", options)
    data = JSON.parse(resp.body)
  end

  def get_user(username, options = {})
    options.merge!({:basic_auth => @auth})
    response = self.class.get("/users/#{username}", options)
    JSON.parse(response.body)
  end

  def twenty_followers(username)
    get_followers(username, @auth).sample(20).each do |rec|
      save_user_info(get_user(rec['login']))    
    end
  end

  def save_user_info(username)
    Cheepcreep::GithubUser.create(
          :login => username['login'], 
          :name => username['name'], 
          :public_repos => username['public_repos'], 
          :followers => username['followers'],
          :following => username['following'],
          :blog => username['blog'])
  end

  def top_users(default = 'redline6561')
    twenty_followers(default)
    order_stat = ARGV[0]
    case order_stat
    when 'public_repos'
      puts 'Top Users sorted by public repo count:'
      puts
      Cheepcreep::GithubUser.order('public_repos').reverse.each do |metric|
        puts "User: #{metric.login}  Public Repo Count: #{metric.followers}"
      end
    when 'following'
      puts 'Top Users sorted by following count:'
      puts
      Cheepcreep::GithubUser.order('following').reverse.each do |metric|
        puts "User: #{metric.login}  Following Count: #{metric.followers}"
      end
    else 'follower'
      puts 'Top Users sorted by following count:'
      puts
      Cheepcreep::GithubUser.order('followers').reverse.each do |metric|
        puts "User: #{metric.login}  Follower Count: #{metric.followers}"
      end
    end
  end
end

#binding.pry
creeps = Github.new
creeps.top_users


