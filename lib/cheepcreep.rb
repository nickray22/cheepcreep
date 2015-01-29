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
  basic_auth ENV['GITHUB_USER'], ENV['GITHUB_PASS']

  def get_followers(username = 'redline6561')
    resp = self.class.get("/users/#{username}/followers")
    data = JSON.parse(resp.body)
  end

  def get_user(username = 'redline6561')
    response = self.class.get("/users/#{username}")
    JSON.parse(response.body)
  end

  def list_gists(username = 'nickray22')
    response = self.class.get("/users/#{username}/gists")
    JSON.parse(response.body)
  end

  def create_gist(options = {})
    info = {:description => "post",
            :public => true,
            :files => {"homework.txt" => {:content => "empty"}}}
    options = {:body => info.to_json}
    response = self.class.post("/gists", options)
    JSON.parse(response.body)
  end

  def edit_gist(id, options = {})
    info = {:description => "edited post", 
            :files => {"homework.txt" => {:content => "update file contents"}},
            :"homework.txt" => {:filename => {"new_homework.txt" => {:content => "modified contents"}}},
            :"new_homework.text" => {:content => "a new file"}} 
    options = {:body => info.to_json}
    response = self.class.patch("/gists/#{id}", options)
    JSON.parse(response.body)
  end

  def delete_gist(id)
    self.class.delete("/gists/#{id}")
  end

  def star_gist(id)
    self.class.put("/gists/#{id}/star")
  end

  def unstar_gist(id)
    self.class.delete("/gists/#{id}/star")
  end
  
  def twenty_followers(username = 'redline6561')
    get_followers(username).sample(20).each do |rec|
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

binding.pry
creeps = Github.new
creeps.top_users


