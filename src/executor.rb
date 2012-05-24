# To change this template, choose Tools | Templates
# and open the template in the editor.
class Calculating_object
  def calculate (in_data, out_data, iter_number)
    out_data=in_data+1
  end
end

class Resource_Manager
  def get_resources

  end
end
class CPU_guard
  def getPermission

  end
  def returnPermission

  end
end

class Calc_object_steer
  def initialize cpuguard
    @cpuguard=cpuguard
  end
  def create_object
    new Calculating_object
  end
  def ask_calculate obj
    @cpuquard.getPermission
    obj.calculate
    @cpuquard.returnPermision
  end
end

class Executor_Scenario
  def initialize
    @resman=new Resouce_Manager
  end

 
  def get_remote_calc_object ip

    
  end
  def create_main_object
    ip=@resman.get_resources
    @my_obj=create_calculating_object_on_resources(ip)

  end
  def create_calculating_object_on_resources(ip)
   
    remote_calc_object_steer=get_remote_calc_object(ip)
    remote_calc_object_steer.create_calculating_object(params)
         
  end
  
  def calculate
         @my_obj.calculate
  end
  

end
puts "Hello World"

calc=Calculating_object.new
puts calc.calculate(5, 6, 1)

