require "ftools"

class DSLElement
 def copyvars
  self.class.instance_variables.each do |var|
   instance_variable_set(var, self.class.instance_variable_get(var))
  end 
 end
end

class Element < DSLElement
 attr_accessor :name

 def initialize(name=nil)
  @name = name
 end

 def self.create_unique_object(name, klass, &blk)
  Object.const_set(name, klass) if not Object.const_defined?(name)
  p = Object.const_get(name).new(name)
  p.class.class_eval(&blk) if block_given?
  p.copyvars
  return p
 end
end


class MultiScaleModel < DSLElement
 attr_accessor :model
 
 def self.generate(&block)
  f = MultiScaleModel.new
  f.class.class_eval(&block) if block_given?
  f.copyvars
  generate_it
  return f
 end
 
 def self.model(namesym, &blk)
  name=namesym.to_s.capitalize
  klass = Class.new(Model)
  @model=Element.create_unique_object(name, klass, &blk)
 # p @model
 end

 def self.generate_it() 
   @model.generate 
 end

 
end


class Model < Element
 attr_accessor  :models, :execution, :implementation_type

 def initialize(name=nil)
  super
 end
 

 def self.implementation_type(mtype)
  @implementation_type = mtype
 end

 def self.language(mtype)
  @language = mtype
 end
 
 def self.timescale(time_scale_prop)
  @timescale ||= Hash.new
  time_scale_prop.each_key do |properties|
   @timescale[properties]= time_scale_prop[properties]
  end
 end

def self.model(namesym, &blk)
  name=namesym.to_s.capitalize
  @models||=Hash.new
  klass = Class.new(Model)
  @models[name]=Element.create_unique_object(name, klass, &blk)
  
 end

def self.execution(&blk)
  klass = Class.new(Execution)
  name=self.name.to_s+"Execution"
  @execution=Element.create_unique_object(name, klass, &blk)

 end

 def generate generator=nil, instance_name=nil

   if (generator.nil?)
       if (@implementation_type==:muscle_application)
        generator=Muscle_Generator.new
       end
   end
   
   @execution.generate generator, self, instance_name
 end
end


class Execution < Element
  attr_accessor  :instances, :execution, :declarations

  def initialize(name=nil)
    super 
  end
  
  def self.join(module1, module2, &blk)
    _name=module1.to_s.capitalize+module2.to_s.capitalize
    @join||=Hash.new
    klass = Class.new(Joining)
    Object.const_set(_name, klass) if not Object.const_defined?(_name)
    p = Object.const_get(_name).new(module1,module2)
    p.class.class_eval(&blk) if block_given?
    p.copyvars
    @join[_name]  = p
  end
 
  def self.declare (type, name, count=-1)
   if(type!=:double_array) 
     puts "error: type of #{name} not supported"
     exit
   end
   @declarations||=Hash.new
   if (@declarations.has_key?(name))
     puts "error: #{name} declared twice"
   end
   @declarations[name]=[type, count] 
  end

  def self.instance(name, nameMod, domain)
   @instances ||= Hash.new
   if @instances.has_key?(name)
      puts "error!!! double instance name"
      exit
   end
   @instances[name] = [nameMod, domain]
  end

  def self.receive(name)
   @execution||=[]
   @execution.push([:receive,name])
   @declarations[name].push(:receive)
  end
 
  def self.send(name)
   @execution||=[]
   @execution.push([:send,name])
   @declarations[name].push(:send)
  end
 
  def self.execute(string_code)
   @execution||=[]
   @execution.push([:execute, string_code])
   #puts string_code
  end

 
 
 
  def self.loop(loop_prop, &blk)
   @execution||=[]
   @loop ||= Hash.new
   loop_prop.each_key do |properties|
    @loop[properties]= loop_prop[properties]
   end
   @new_exec=[]
   @execution.push([:loop, @loop,@new_exec])
   @old=@execution
   @execution=@new_exec
   blk.call if block_given?
   @execution=@old
  end

  def generate generator, my_model, instance_name=nil
   # TODO - other types
   p my_model.implementation_type
 
    if (my_model.implementation_type==:muscle_application)
         
         generator.generate_build_xml
         
         if (!instances.nil?)
               @instances.each_key do |name|
               my_model.models[@instances[name][0].to_s.capitalize].generate generator, name
     
    
               end
         end
         if (!@join.nil?)
           @join.each_key do |name|
                @join[name].generate generator
            end
         end
     end
  
     if (my_model.implementation_type==:muscle_kernel)
         if (!instance_name.nil?)
            generator.generate_kernel(instance_name, @declarations, @execution)
         else
           generator.generate_kernel(my_model.name, @declarations, @execution)
         end

     end
    
       
   

  end
 
    
  
end
class Joining < DSLElement
  def initialize(module1,module2)
    @module1=module1
    @module2=module2
  end


  def self.tie(portA, portB)
    @port_connections||=[]
    @port_connections.push([portA, portB])
  end
  def generate generator
    generator.generate_cxa(@module1, @module2, @port_connections)
  end
 end






class Muscle_Generator
 def generate_kernel (instance_name, declarations, execution)
        @generated_kernels||=[]
        @generated_kernels.push instance_name
     	_instance_name_capital=instance_name.to_s.capitalize 
	_dir_name="generatedExamples"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
	_dir_name+="/maskExample1"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
	_dir_name+="/src"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
	_dir_name+="/mask"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
	_dir_name+="/example"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
     	open("#{_dir_name}/#{_instance_name_capital}.java", 'w') { |f|
                @my_file=f
     		generate_prefix _instance_name_capital 
     		generate_ports declarations 
     		generate_get_scale
        generate_execution_begin
     		generate_execution_declarations declarations 
     		generate_execution_body execution, 1
     		generate_end 
                f.close
        }
 end

 def generate_prefix instance_name
   @my_file.puts "

package mask.example;

import muscle.core.ConduitExit;
import muscle.core.ConduitEntrance;
import muscle.core.Scale;
import muscle.core.kernel.RawKernel;
import java.math.BigDecimal;
import javax.measure.DecimalMeasure;
import javax.measure.quantity.Duration;
import javax.measure.quantity.Length;
import javax.measure.unit.SI;


/**
a simple java example kernel generated from MASK skeleton
*/
public class #{instance_name} extends muscle.core.kernel.CAController {
"
 end


 def generate_ports declarations
   if (!declarations.nil?)
    declarations.each_key do |name|
       if declarations[name][2]==:send
          @my_file.puts "\tprivate ConduitEntrance<double[]> #{name}pipe;"        
       end
       if declarations[name][2]==:receive
          @my_file.puts "\tprivate ConduitExit<double[]> #{name}pipe;"        
       end
    end  
    @my_file.puts " "
    @my_file.puts "\tprotected void addPortals(){"

      declarations.each_key do |name|
       if declarations[name][2]==:send
          @my_file.puts "\t\t#{name}pipe= addEntrance(\"#{name}\",1, double[].class);"        
       end
       if declarations[name][2]==:receive
          @my_file.puts  "\t\t#{name}pipe= addExit(\"#{name}\",1, double[].class);"
       end
    end  

    @my_file.puts "	}"

   end 
 end
 def generate_get_scale
   @my_file.puts "
\tpublic muscle.core.Scale getScale() {
\t\tDecimalMeasure<Duration> dt = DecimalMeasure.valueOf(new BigDecimal(1), SI.SECOND);
\t\tDecimalMeasure<Length> dx = DecimalMeasure.valueOf(new BigDecimal(1), SI.METER);
\t\treturn new Scale(dt,dx);
\t}
   "
 end
def generate_execution_begin
      @my_file.puts "\tprotected void execute(){"
    
end
 def generate_execution_declarations declarations
   if (!declarations.nil?)
    declarations.each_key do |name|
       if declarations[name][2]==:send
          @my_file.puts "\t\tdouble[] #{name} = new double[#{declarations[name][1]}];"
       end
       if declarations[name][2]==:receive
          @my_file.puts "\t\tdouble[] #{name} = null;"   
       end
    end
   end
 end

 def generate_execution_body(execution_a, deep)
   if (!execution_a.nil?)
      execution_array=execution_a.clone
      while !execution_array.empty? do
        @token=execution_array.shift
        if (@token[0]==:receive)
          @my_file.puts "\t"*(deep+1)+"#{@token[1]}=#{@token[1]}pipe.receive();"
        end
        if (@token[0]==:send)
          @my_file.puts "\t"*(deep+1)+"#{@token[1]}pipe.send(#{@token[1]});"
        end
        if (@token[0]==:execute)
          @ext_code=@token[1].gsub("\n", "\n"+"\t"*(deep+1))
          @my_file.puts "\t"*(deep+1)+"#{@ext_code}"
        end
        if (@token[0]==:loop)
          # TODO - unique maskIterator !
          @my_file.puts "\t"*(deep+1)+"for (int maskIterator=#{@token[1][:start_time]}; maskIterator<#{@token[1][:stop_time]}; maskIterator+=#{@token[1][:step_time]}){"
          generate_execution_body @token[2],  deep+1
          @my_file.puts "\t"*(deep+1)+"}"
        end
      end
   end
 end

 def generate_end
  @my_file.puts "\t}"
  @my_file.puts "}"
 end

def generate_build_xml
  _dir_name="generatedExamples"
   Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
  _dir_name+="/maskExample1"
  Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
  File.copy("build.xml_template","generatedExamples/maskExample1/build.xml")
end

def generate_cxa kernel1, kernel2, connection_scheme

  _dir_name="generatedExamples"
   Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
  _dir_name+="/maskExample1"
  Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
  _dir_name+="/cxa"
  Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        

  open("#{_dir_name}/maskExample1.cxa.rb", 'w') { |f|

    f.puts "

# configuration file for a MUSCLE CxA
abort \"this is a configuration file for to be used with the MUSCLE bootstrap utility\"   if __FILE__ == $0

# add build for this cxa to system paths (i.e. CLASSPATH)
m = Muscle.LAST
m.add_classpath File.dirname(__FILE__)+\"/../build/maskExample1.jar\"

# configure cxa properties
cxa = Cxa.LAST

cxa.env[\"cxa_path\"] = File.dirname(__FILE__)

# declare kernels
"
	@generated_kernels.each do |name|
        	_string_key=name.to_s.capitalize
		f.puts "cxa.add_kernel('#{name}', \"mask.example.#{_string_key}\")"
	end

	f.puts "
# configure connection scheme
cs = cxa.cs
"
f.puts "cs.attach('#{kernel1}' =>'#{kernel2}' ) {"
	connection_scheme.each do |tied_ports|
        		f.puts "tie('#{tied_ports[0]}', '#{tied_ports[1]}')"
  end
f.puts "}"

  }

end
end


if ARGV.size > 0
  load ARGV.shift
else
  puts "Usage: ruby mask.rb filename"
end

