# To change this template, choose Tools | Templates
# and open the template in the editor.


class DSLElement
 def copyvars
  self.class.instance_variables.each do |var|
   instance_variable_set(var, self.class.instance_variable_get(var))
  end 
 end
end
puts "Hello World"