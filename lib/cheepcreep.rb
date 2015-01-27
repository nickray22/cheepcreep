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

  def self.get_followers(screen_name)
    HTTParty.get("#{base_uri}/users/#{screen_name}/followers")
  end

  def self.get_user(screen_name)
    HTTParty.get("#{base_uri}/users/#{screen_name}")
  end
end

class CheepcreepApp

  def twenty_followers(screen_name)
    Github.get_followers(screen_name).sample(20).each do |rec|
      save_user_info(Github.get_user(rec['login']))    
    end
  end

  def save_user_info(screen_name)
    Cheepcreep::GithubUser.create(
          :login => screen_name['login'], 
          :name => screen_name['name'], 
          :public_repos => screen_name['public_repos'], 
          :followers => screen_name['followers'],
          :following => screen_name['following'],
          :blog => screen_name['blog'])
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

creeps = CheepcreepApp.new
creeps.top_users


