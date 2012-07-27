#$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'sinatra'
require './main'
require 'haml'
run Sinatra::Application