$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
    $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'bundler/setup'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader'
require 'haml'
require 'lib/connectors'

set :root, File.dirname(__FILE__)

get '/' do
  haml :index
end

get '/application.js' do
  coffee :application
end

get '/application.css' do
  sass :application
end

get '/blogs' do
  json BlogConnector.fetch!
end

get '/tweets' do
  json TwitterConnector.fetch!
end

get '/commits' do
  json GithubConnector.fetch!
end
