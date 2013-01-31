# To change this template, choose Tools | Templates
# and open the template in the editor.

#puts "Hello World"
class Person
  attr_accessor :cos , :cos3
  @@cos2="cos"
  def initialize
  @cos="ja"
  

 end
  def self.cos2
    puts @@cos2
    puts @cos3=9
  end
end

Person.class_eval do
 
  def say_hello
   puts @cos
  end
end
Person.instance_eval do
  def say_hello2
   puts @cos
  end
end

jimmy = Person.new

class << jimmy
  def say_hello3
    puts "Hello 3!"
  end
end
Person.cos2
#jimmy.say_hello
#jimmy.say_hello3 # "Hello!"
#jimmy.class.say_hello3