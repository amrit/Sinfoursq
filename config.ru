# Gemfile
#require "rubygems"
#require "bundler/setup"
#require "sinatra"

require "./main"
 
set :run, false
set :raise_errors, true
 
run Sinatra::Application