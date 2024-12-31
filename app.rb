require 'sinatra'
require 'logger'

set :logging, :debug

get '/' do
  logger.info "inside home"
  "Hallo World"
end
