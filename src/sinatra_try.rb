# To change this template, choose Tools | Templates
# and open the template in the editor.


require 'rubygems'

# If you're using bundler, you will need to add this
#require 'bundler/setup'

require 'sinatra'
@calculations||=[]
post '/calculations' do
      "You said '#{params[:message]}'"
      @calculations.push(:message)
    end


get '/calculations/' do
  @calculations
end
get '/resources2/time' do
  "Hello world, it's #{Time.now} at the server!"
end