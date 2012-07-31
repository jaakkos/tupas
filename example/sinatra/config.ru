require 'rubygems'
require 'bundler/setup'
require 'tupas'
require 'sinatra'
require './app.rb'

ENV['RACK_ROOT'] = File.expand_path('.')

use Tupas::Rack

run Sinatra::Application
