# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'drb'
require "net/http"
require "uri"
require 'rest_client'
class Resource_Manager
  #attr_accessor :resman_uri
  def initialize
    @init_port=47439
    @resources||=Hash.new
    @resman_uri="druby://ubuntu:47432"
    DRb.start_service @resman_uri, self
    puts @resman_uri
  end
  
  def get_resources requirements

    if (@resources[requirements]==nil)
      @resources[requirements]=1
      puts "getting new resources"
      IO.popen("ruby /home/kzajac/MASK/src/calc_object_factory.rb #{@init_port} ")
      13.times do
      puts "waiting for cacl factory ..."
        sleep(1)
      end
      @resources[requirements]=@init_port
      @init_port=@init_port+1 
    end
    while (@resources[requirements]==1) 

        puts "resources are currently allocated - waiting  ..."
        sleep(1)
    end
    
    return @resources[requirements]
  end

end


class Executor_Scenario
  def initialize
    @resman=Resource_Manager.new
  
  end

  def create_object filename
    _factory_port=@resman.get_resources 1
   
     _url="http://localhost:#{_factory_port}"
      puts _url
     res= RestClient.post "http://localhost:#{_factory_port}/filename/#{filename}", ""
     puts res

  end
  
  
  
  

end
puts "Hello World"
exec=Executor_Scenario.new
exec.create_object "LU_factorization.rb"
#exec.create_object "LU_factorization.rb"
puts "po sprawie #{exec}"

#exec.ask_calculate(1, 8)
#calc=Calculating_object.new
#puts calc.calculate(5, 6, 1)

DRb.thread.join
