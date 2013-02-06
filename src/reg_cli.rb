require 'rubygems'
require "rest_client"
require "json"

for iter in 1..10 do

  jdata = {"name" =>"LU", "id"=>"1", "predcessor"=>"none", "iteration"=>iter}.to_json

  puts jdata

  res= RestClient.post 'http://localhost:4567/calculations', {:data => jdata}, {:content_type => :json, :accept => :json}

  p res
end

res= RestClient.get 'http://localhost:4567/calculations/'

p res

#tablica=JSON.parse(res)
#puts tablica

 
    