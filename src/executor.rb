# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'drb'


class Resource_Manager
  def get_resources
     puts "getting resources"
     ip="druby://ubuntu:38008"
  end
end


class Executor_Scenario
  def initialize
    @resman=Resource_Manager.new
  end

 
  def get_remote_calc_object url

    remote_calc_object = DRbObject.new nil, url
    puts remote_calc_object
     return remote_calc_object
  end

  def create_main_object
    url=@resman.get_resources
    @my_obj=get_remote_calc_object(url).create_object

  end
  
  
  def calculate
         get_remore_calc_object.ask_calculate(@my_obj)
  end
  

end
puts "Hello World"
exec=Executor_Scenario.new.get_remote_calc_object "druby://ubuntu:47583"
exec.ask_calculate(1, 8)
#calc=Calculating_object.new
#puts calc.calculate(5, 6, 1)

