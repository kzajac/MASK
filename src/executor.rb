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
class Remote_calc_object_creator
  
end
class Executor_Scenario
  def initialize
    resman=new Resouce_Manager
  end
  def get_resources
       ip=resman.get_resources
  end
  def create_calculating_object_on_resources(ip)
         remote_calc_object_creator.create_calculating_object(params)
         
  end
  
  def calculate
         @my_obj.calculate
  end
  def spawn
     create_calculating_object_on_resources(resman.get_resources)
     
  end
  def receive

  end
  def send
    
  end

end
puts "Hello World"

calc=Calculating_object.new
puts calc.calculate(5, 6, 1)

