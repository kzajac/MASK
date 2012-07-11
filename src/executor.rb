# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'drb'


class Resource_Manager
  #attr_accessor :resman_uri
  def initialize
    @init_port=47439
    @resources||=Hash.new
    DRb.start_service nil, self
     puts DRb.uri
    @resman_uri=DRb.uri
  end
  
  def get_resources requirements

    if (@resources[requirements]==nil)
      @resources[requirements]=1
      puts "getting new resources"
      url="druby://ubuntu:#{@init_port}"
      IO.popen("ruby /home/kzajac/MASK/src/calc_object_factory.rb #{url} #{@resman_uri}")
      13.times do
      puts "waiting for cacl factory ..."
        sleep(1)
      end
      @init_port=@init_port+1
      @resources[requirements]=url
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

 
  def get_remote_calc_object_factory url
    
           remote_calc_object = DRbObject.new nil, url
           puts remote_calc_object
           
   
    
    
   
     return remote_calc_object
  end

  def create_object filename
    url=@resman.get_resources 1
    @my_obj=get_remote_calc_object_factory(url).create_object filename
         
    
    

  end
  
  
  
  

end
puts "Hello World"
exec=Executor_Scenario.new
exec.create_object "LU_factorization.rb"
 exec.create_object "LU_factorization.rb"
puts "po sprawie #{exec}"

#exec.ask_calculate(1, 8)
#calc=Calculating_object.new
#puts calc.calculate(5, 6, 1)

DRb.thread.join
