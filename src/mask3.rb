require "/home/kzajac/MASK/src/calculation_client.rb"

require 'rubygems'
require 'linalg'
require 'json'

include Linalg
include Calculation_clients

class DSLThing
 def copyvars
  self.class.instance_variables.each do |var|
    p var
   instance_variable_set(var, self.class.instance_variable_get(var))
  end
 end

 def self.singleton_class
  class << self; self; end
 end
end

class Executor < DSLThing
 attr_accessor :modules, :people

 def self.create(&block)
  f = Executor.new
  f.class.instance_eval(&block) if block_given?
  f.copyvars
  return f
 end

 def self.submodule(name, &blk)
  @modules ||= Hash.new
  klass = Class.new(Submodule)
  Object.const_set(name, klass) if not Object.const_defined?(name)
  p = Object.const_get(name).new
  p.name = name
  p.class.class_eval(&blk) if block_given?
  p.class.instance_variable_set("@myexec",self)
  puts "copyvars"
   p.copyvars
  @modules[name] = p
 end
 def start_running(name)
   @modules[name].perform
 end
 
end

class Supsubmodule < DSLThing
 attr_accessor :name, :myexec

 def initialize(name=nil)
  @name=name
 
 end
end
class Submodule < Supsubmodule
 @@zasoby||=Hash.new
 def initialize(name=nil)
  @name = name

 
  super
 end

 def self.process(&routine)
  @routine = routine
 end

 def self.spawn other_name
   
 
  myname=name
  puts "#{name} spawning #{other_name}, #{@myexec}"
  @myexec.instance_eval do
     @modules[other_name].perform myname
    
 
  end


 end

 #def self.define_calculations(name, &trick_definition)
  
 
  #singleton_class.class_eval do
  # define_method name, &trick_definition
 # end
# end
def self.define_calculations(&trick_definition)
    
   @calculations_method=trick_definition
  
  
 end
 def self.define_initial_state(&state_definition)
  # puts state_definition
   @state_defin=state_definition
 end
 
 def self.calculate
   #wyslij zadanie wywolania iteracji do zasobuater, podaj swoj id.
   @@zasoby[name].request_calculations(name)
   #@calculations_method.call
   
 
 end
 def self.get_results
   #pytamy o swoje rezultaty swoj zasob obliczeniowy i wszystkie spawny
   
   
 end
 def perform mypredcessor="none"
  
   #TODO informujemy przodka o obliczeniach (zanim stworzymy zasob !)
   
  # tworzymy nowy zasob lub korzystamy z obecnego dla tego typu obliczen
   #stawiamy tam serwis obliczeniowy
   #przekazujemy przodka

   @@zasoby[name]=Calculation_client.new("localhost",4567)
   @@zasoby[name].request_start(name,mypredcessor)
   @@zasoby[mypredcessor].add_spawn_info(_my_remote_id) unless @@zasoby[mypredcessor].nil?

  @state_defin.call unless @state_defin.nil?
  puts "#{name} will now perform..."
  puts @routine.to_json
  @routine.call
  @@zasoby[name].request_end(name,mypredcessor)
 # TODO na zdalnym zasobie po skonczeniu informujemy przodka
 # puts "Let's hear some applause for #{name}!"
 end

 
end

module_set = Executor.create do
 

 submodule "LU_factor" do
  process do

  for i in 0..1
    #wywolujemy request obliczen na zasobie
   calculate
   spawn "LU_factor_fined"
  end
  end

   define_initial_state do
     @state1=0
   end

  define_calculations  do 
    @state1=@state1+1
    puts @state1
    beginning = Time.now
    a = DMatrix.rand(1600, 1600)
    l, u = a.lu
    File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("Time elapsed #{Time.now - beginning} seconds\n")}
    puts  "Time elapsed #{Time.now - beginning} seconds\n"
    "wynik_obliczen"
  end

  
 end

 submodule "LU_factor_fined" do
  process do

  calculate
    
  end

  define_calculations do

    beginning = Time.now
    a = DMatrix.rand(1600, 1600)
    l, u = a.lu
    File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("Time elapsed #{Time.now - beginning} seconds\n")}
    puts  "Time elapsed #{Time.now - beginning} seconds\n"
    "wynik obliczen 3"
  end


 end
end




#puts module_set.modules["LU_factor"]
module_set.start_running "LU_factor"
