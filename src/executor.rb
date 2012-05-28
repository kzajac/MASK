# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'drb'


class Resource_Manager
  def get_resources
     puts "getting resources"
     ip="druby://ubuntu:40664"
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

  def create_main_object
    url=@resman.get_resources
    @my_obj=get_remote_calc_object_factory(url).create_object

  end
  
  
  
  

end
puts "Hello World"
exec=Executor_Scenario.new.create_main_object
#exec.ask_calculate(1, 8)
#calc=Calculating_object.new
#puts calc.calculate(5, 6, 1)

