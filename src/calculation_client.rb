module Calculation_clients


require 'rubygems'
require "rest_client"
require "json"
def testm
jdata = {"name" =>"LU", "id"=>"1", "predcessor"=>"none", "iteration"=>"begin"}.to_json

 puts jdata

 res= RestClient.post 'http://localhost:4567/calculations', {:data => jdata}, {:content_type => :json, :accept => :json}
for iter in 1..10 do

  jdata = {"name" =>"LU", "id"=>"1", "predcessor"=>"none", "iteration"=>iter}.to_json

  puts jdata

  res= RestClient.post 'http://localhost:4567/calculations', {:data => jdata}, {:content_type => :json, :accept => :json}

  p res
end
jdata = {"name" =>"LU", "id"=>"1", "predcessor"=>"none", "iteration"=>"final"}.to_json

 puts jdata

 res= RestClient.post 'http://localhost:4567/calculations', {:data => jdata}, {:content_type => :json, :accept => :json}
#res= RestClient.get 'http://localhost:4567/calculations/'

p res

end

class Calculation_client
  def initialize (host, port)
    @host=host
    @port=port
  end
  def request_calculations (name, id, predcessor)
    jdata = {"name" =>name, "id"=>id, "predcessor"=>predcessor, "iteration"=>"middle"}.to_json
    puts jdata
    res= RestClient.post "http://#{@host}:#{@port}/calculations", {:data => jdata}, {:content_type => :json, :accept => :json}
    p res
  end
  def request_start(name,id, predcessor)
    jdata = {"name" =>name, "id"=>id, "predcessor"=>predcessor, "iteration"=>"begin"}.to_json
    puts jdata
    res= RestClient.post "http://#{@host}:#{@port}/calculations", {:data => jdata}, {:content_type => :json, :accept => :json}
    p res
  end
  def request_end(name,id, predcessor)
    jdata = {"name" =>name, "id"=>id, "predcessor"=>predcessor, "iteration"=>"finish"}.to_json
    puts jdata
    res= RestClient.post "http://#{@host}:#{@port}/calculations", {:data => jdata}, {:content_type => :json, :accept => :json}
    p res
  end
end
 
end