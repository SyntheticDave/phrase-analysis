require 'sinatra'
require './app/phrase_analyser'
require 'pry'

get '/' do
  haml :index
end

post '/analysis' do
  options = { counter: params[:options][:counter], preprocessor: params[:options][:preprocessor] }
  text = params[:text]

  analyser = PhraseAnalyser.new(text, options)
  haml :analysis, locals: { analyser: analyser }
end
