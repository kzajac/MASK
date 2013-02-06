# To change this template, choose Tools | Templates
# and open the template in the editor.


require 'rubygems'

# If you're using bundler, you will need to add this
#require 'bundler/setup'

require 'sinatra'
require 'json'
class Calculations

  def self.add element
   @calculations||=[]
   @calculations.push(element)
  end
  def self.calculations
    @calculations
  end
 end
post '/calculations' do
      #"You said '#{params[:message]}'"
      jdata = params[:data]
      for_json = JSON.parse(jdata)
      Calculations.add(for_json)
      #@calculations.push(:message)
      "hello"
    end


get '/calculations/' do
 puts Calculations.calculations
 "kk"
end
get '/resources2/time' do
  "Hello world, it's #{Time.now} at the server!"
end