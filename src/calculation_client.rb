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
  def initialize (host, port, name, predcessor)
    @host=host
    @port=port
    @name=name
    @predcessor=predcessor
  end
  def request_calculations (name)
    jdata = {"name" =>name,  "predcessor"=>"n/a", "iteration"=>"middle"}.to_json
    puts jdata
    RestClient.post "http://#{@host}:#{@port}/calculations", {:data => jdata}, {:content_type => :json, :accept => :json}
  end
  def add_spawn_info(id)
    jdata = {"id"=>id}.to_json
    puts jdata
    RestClient.post "http://#{@host}:#{@port}/spawns", {:data => jdata}, {:content_type => :json, :accept => :json}
    
  end
  def request_start(name, predcessor)
    jdata = {"name" =>name,  "predcessor"=>predcessor, "iteration"=>"begin"}.to_json
    puts jdata
    res=RestClient.post "http://#{@host}:#{@port}/calculations", {:data => jdata}, {:content_type => :json, :accept => :json}
    JSON.parse(res)["index"]
  end
  def request_end(name, predcessor)
    jdata = {"name" =>name,  "predcessor"=>predcessor, "iteration"=>"finish"}.to_json
    puts jdata
    RestClient.post "http://#{@host}:#{@port}/calculations", {:data => jdata}, {:content_type => :json, :accept => :json}
    
  end
end
 
end