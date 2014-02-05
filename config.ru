# TODO: Remove pry from overall config
require 'pry'

Dir[File.dirname(__FILE__) + '/extensions/**/*.rb'].each { |file| require file }

require './app/phrase-analysis'
run Sinatra::Application
