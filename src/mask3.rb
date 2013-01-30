require 'linalg'
include Linalg
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
  p.myexec="haha"
  p.class.class_eval(&blk) if block_given?
  p.class.instance_variable_set("@myexec",self)
  puts "copyvars"
   p.copyvars
  @modules[name] = p
 end
end

class Supsubmodule < DSLThing
 attr_accessor :name, :myexec

 def initialize(name=nil)
  @name=name
 
 end
end
class Submodule < Supsubmodule
 def initialize(name=nil)
  @name = name
 # p @namee
  @myexec=nil
  super
 end

 def self.process(&routine)
  @routine = routine
 end

 def self.spawn other_name
  puts "#{name} spawning #{other_name}, #{@myexec}"
  @myexec.instance_eval do
    @modules[other_name].perform
  end
 end

 def self.define_calculations(name, &trick_definition)
  singleton_class.class_eval do
   define_method name, &trick_definition
  end
 end

 def perform
  puts "#{name} will now perform..."
  puts @routine
  @routine.call
  puts "Let's hear some applause for #{name}!"
 end

 
end

module_set = Executor.create do
 

 submodule "LU_factor" do
  process do
  
   lu_factorization
   spawn "LU_factor_fined"
  
  end

  define_calculations "lu_factorization" do

    beginning = Time.now
    a = DMatrix.rand(1600, 1600)
    l, u = a.lu
    File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("Time elapsed #{Time.now - beginning} seconds\n")}
    puts  "Time elapsed #{Time.now - beginning} seconds\n"
  end

  
 end

 submodule "LU_factor_fined" do
  process do

   lu_factorization
    
  end

  define_calculations "lu_factorization" do

    beginning = Time.now
    a = DMatrix.rand(1600, 1600)
    l, u = a.lu
    File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("Time elapsed #{Time.now - beginning} seconds\n")}
    puts  "Time elapsed #{Time.now - beginning} seconds\n"
  end


 end
end

module_set.modules["LU_factor"].perform