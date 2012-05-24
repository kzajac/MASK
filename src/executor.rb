# To change this template, choose Tools | Templates
# and open the template in the editor.
class Calculating_object
  def calculate (in_data, out_data, iter_number)
    out_data=in_data+1
  end
end

class Resource_Manager
  def get_resources
     puts "getting resources"
  end
end
class CPU_guard
  def getPermission
      puts "getting permissions"
  end
  def returnPermission
      puts "return permissions"
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
    @my_obj=get_remote_cacl_object(ip).create_object

  end
  
  
  def calculate
         get_remore_cacl_object.calculate(@my_object)
  end
  

end
puts "Hello World"

calc=Calculating_object.new
puts calc.calculate(5, 6, 1)

