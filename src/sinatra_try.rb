# To change this template, choose Tools | Templates
# and open the template in the editor.


require 'rubygems'

# If you're using bundler, you will need to add this
#require 'bundler/setup'

require 'sinatra'

post '/calculations' do
      "You said '#{params[:message]}'"
      @calculations||=[]
      @calculations.push(:message)
      "hello"
    end


get '/calculations/' do
  @calculations.each {|_ind| puts @calculations[_ind]}
 
end
get '/resources2/time' do
  "Hello world, it's #{Time.now} at the server!"
end