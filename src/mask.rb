#require "ftools"
#TODO
#rozdzielic jary
require "net/http" 
require "uri"
require "rest_client"
$jar_destination_dir="/home/kzajac/stagein"
$jar_final_location="grass1.man.poznan.pl:/home/mapper03/AntAndElephantWithFiles/build/"
$install_dir="/home/kzajac/MASK/"
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
 
 def self.application_module(namesym, &blk)

   
   @main_model_name=namesym.to_s.gsub /(_)/, ""
   @main_model_name.capitalize!
   
  name=namesym.to_s.capitalize
  klass = Class.new(Model)
  @model=Element.create_unique_object(name, klass, &blk)
 
 end

 def self.generate_it()
   @model.generate @main_model_name
 end

 
end


class Model < Element
 attr_accessor :timescale, :spacescale, :models, :execution, :implementation_type, :name, :register_xmml_data, :junction_type, :extra_imports

 def initialize(name=nil)
  super
 end
 
 def self.register_xmml_data
   @register_xmml_data=true
   
 end
 def self.implementation_type(mtype)
    @implementation_type = mtype
    
   
 end
 
 def self.language(mtype, additional_data=nil)
  @language = mtype
  if (@language==:java)
    unless additional_data.nil?
      additional_data.each_key do |key|
        if (key==:extra_imports)
          @extra_imports=additional_data[key]
         
        end


      end
    end

   
  end

  end
 
 
 def self.timescale(time_scale_prop)
  @timescale ||= Hash.new
  time_scale_prop.each_key do |properties|
   @timescale[properties]= time_scale_prop[properties]

   
  end
 end
def self.spacescale(space_scale_prop)
   @spacescale ||= []
   @spacescale.push(space_scale_prop)

end
def self.junction_type(juction_type)
   @junction_type=juction_type

end
def self.application_module(namesym, &blk)
  name=namesym.to_s.capitalize
  @models||=Hash.new
  klass = Class.new(Model)
  @models[name]=Element.create_unique_object(name, klass, &blk)
  
 end

def self.execution(&blk)
  klass = Class.new(Execution)
  name=self.name.to_s+"Execution"
  @execution=Element.create_unique_object(name, klass, &blk)
 
  if (@implementation_type==:muscle_kernel)
  
  @execution.class.class_exec(@timescale, @spacescale) do |t, s|
 # @execution.class.class_eval do
  #  t=@timescale
   # s=@spacescale
        unless (t.nil?)

        
            t.each_key do |key|
              declare_param "value_time_#{key}".to_sym=>t[key].split(' ')[0].to_i
            end
        end
        unless (s.nil?)
          s.each do |val|
            declare_param "value_space_#{val[:id]}_delta".to_sym=>val[:delta].split(' ')[0].to_i
            declare_param "value_space_#{val[:id]}_max".to_sym=>val[:max].split(' ')[0].to_i
          end
        end
     end

  @execution.copyvars
  end
 end

 def generate main_name
   unless (models.nil?)

             models.each_key do |name|

                  models[name].generate main_name

             end
   end
   @register_xmml_data||=false
   unless @execution.nil?
    @execution.generate self, main_name
   end

 end
end


class Execution < Element
  attr_accessor  :instances, :execution, :declarations, :params

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
 
  def self.declare_port (name, type ,count=-1)
   if((type!=:double_array)&&(type!=:file))
     puts "error: type of #{name} not supported"
     exit
   end

   @declarations||=Hash.new
   if (@declarations.has_key?(name))
     puts "error: #{name} declared twice"
   end
   @declarations[name]=[type, count] 
  end
  def self.declare_param(key_value)
   @params||=Hash.new
   key_value.each_key do |key|
    
     if (@params.has_key?(key))
        puts "error: #{key} declared twice"
     else
       @params[key]=key_value[key]
     end
   end
  end
  def self.instance(name, nameMod, domain=nil)
   @instances ||= Hash.new
   if @instances.has_key?(name)
      puts "error!!! double instance name"
      exit
   end
   # TODO check if such module exists !
   @instances[name] = [nameMod, domain]
  end

  def self.receive(name, operator_type=:solver)
   if (!@declarations.has_key?(name))
     puts "error: #{name} received but not declared"
   end
   @execution||=[]
   
   @execution.push([:receive,name])
   @declarations[name].push(:receive)
   @loop_deep||=0;
    if(@loop_deep>0)
      if (operator_type==:solver)
       @declarations[name].push(:S)
      else
        @declarations[name].push(:B)
      end
    else
      @declarations[name].push(:finit)
    end
  end
 
  def self.send(name)
   if (!@declarations.has_key?(name))
     puts "error: #{name} sent but not declared"
   end
   @execution||=[]
   @execution.push([:send,name])
   @declarations[name].push(:send)
   @loop_deep||=0;
    if(@loop_deep>0)
       @declarations[name].push(:Oi)
    else
      @declarations[name].push(:Of)
    end
  end
 
  def self.execute(string_code)
   @execution||=[]
   @execution.push([:execute, string_code])
   
  end

 
 
 
  def self.loop(loop_prop, &blk)
   @loop_deep||=0
   @loop_deep=@loop_deep+1
   
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
   @loop_deep=@loop_deep-1

  end

  def generate  my_model, main_name
   # TODO - other types
   
   if(my_model.register_xmml_data)
     XMML_Generator.new.generate my_model.name, my_model.implementation_type, main_name, @declarations, @params, @execution, my_model.spacescale, my_model.timescale, my_model.junction_type
   end
   if (my_model.implementation_type.to_s.include?("snippet"))
     Snippet_Generator.new.generate main_name,my_model, @execution
   else
   if (my_model.implementation_type==:muscle_application)
        
         generator=Muscle_Generator.new
         cxa_params||= Hash.new
          unless (@instances.nil?)

             @instances.each_key do |name|
              
                    model_params||=my_model.models[@instances[name][0].to_s.capitalize].execution.params
                    unless model_params.nil?
                        model_params.each_key do |key|
                          unique_key="#{name}:#{key}"
                          cxa_params[unique_key]=model_params[key]
                        end
                    end
                 # end
             end
         end
         connection_scheme||=[]
         unless (@join.nil?)
           @join.each_key do |name|
                cs_element=[@join[name].module1, @join[name].module2, @join[name].port_connections]
                connection_scheme.push(cs_element)
            end
         end
         generator.generate_cxa(main_name,  cxa_params, @instances, connection_scheme)
         generator.generate_build_xml main_name, my_model.name, @instances
  else
     if (my_model.implementation_type==:muscle_kernel)
         generator=Muscle_Generator.new
        
         generator.generate_kernel(main_name, my_model, @declarations, @execution, @params)
        
         generator.generate_build_xml main_name, my_model.name, @instances

     else
       p "error: implementation type #{my_model.implementation_type} not supported"
       exit
     end
  end
   end
  end
  
end
class Joining < DSLElement
   attr_accessor  :module1, :module2, :port_connections
  def initialize(module1,module2)
    @module1=module1
    @module2=module2
  end


  def self.tie(portA, portB)
    @port_connections||=[]
    @port_connections.push([portA, portB])
  end
  
 end




class XMML_Generator

  def create_ports_array ports
   ports_array||=[]
    ports.each_key do |key|
      case(ports[key][2])
      when :send
        ports_array.push({"id"=>key.to_s,"datatype"=>ports[key][0].to_s,"inout"=>"out", "operator"=>ports[key][3].to_s})
      when :receive
        ports_array.push({"id"=>key.to_s,"datatype"=>ports[key][0].to_s,"inout"=>"in", "operator"=>ports[key][3].to_s})
      end
    end
    return ports_array
  end
  def create_hash_time_scale timescale
       hash_time_scale||={}
      if (timescale.nil?)
         hash_time_scale={"delta"=>"1", "max"=>"1"}
       else
         hash_time_scale={"delta"=>timescale[:delta], "max"=>timescale[:max]}
       end
      return hash_time_scale
  end
  def create_array_space_scales spacescale
        array_space_scales||=[]
        unless spacescale.nil?
             spacescale.each do |spaces|

                array_space_scales.push({"max"=>spaces[:max], "delta"=>spaces[:delta], "id"=>spaces[:id]})
             end
        end
        return array_space_scales

  end
  def create_array_params params
    array_params||=[]
    unless params.nil?
      params.each_key do |key|
        if(key.to_s.include? "file")
          typ="asset"
        end
       if(key.to_s.include? "value_space")
          typ="dependsOnSpacescale"
       end
       if (key.to_s.include? "value_time")
          typ= "dependsOnTimescale"
       end

       if params[key].is_a? Integer
          typ||=""
          typ=typ+":number"
       end
      if params[key].is_a? String
          typ||=""
          typ=typ+":string"
       end
       if params[key].is_a? Float
          typ||=""
          typ=typ+":number"
       end

        typ||="unknown"
        array_params.push({"id"=>key.to_s, "type"=>typ, "value"=>params[key].to_s})
      end
    end
    return array_params
  end
  def determine_interpreter implementation_type
    case (implementation_type)
       when (:muscle_kernel)
         return ["muscle", "2010-01-11_13-51-27"]
       when(:lammps_snippet)
         return ["lammps", "9 Feb 11"]
       when (:perl_snippet)
          return ["perl", "5.8.8"]
    end
    return "unknown"
  end
  def determine_configuration_file implementation_type, execution
    if (implementation_type.to_s.include? "snippet")
      execution.each do |element|
      
              if (element[0]==:execute)
                return element[1]
              end
            end
      
    end
    return ""
  end

  def generate name, implementation_type, main_name, ports, params, execution, spacescale, timescale, junctiontype
     
     unless (timescale.nil? && spacescale.nil?)
      p "------------submodule-------------"
       
         hash_time_scale=create_hash_time_scale timescale
         
         array_ports=create_ports_array(ports)

      unless (spacescale.nil?)
              array_space_scale=create_array_space_scales spacescale
              res= RestClient.post 'http://gs2.mapper-project.eu:1234/add_base/Submodel', {"id"=>"#{name}", "name"=>"#{name}",  "timescale"=>hash_time_scale,
                 "spacescales[]"=>array_space_scale, "ports[]"=>array_ports}
       
       else
              res= RestClient.post 'http://gs2.mapper-project.eu:1234/add_base/Submodel', {"id"=>"#{name}", "name"=>"#{name}", "timescale"=>hash_time_scale,
                "ports"=>array_ports}
              
       end
       if (res.code==200)
         p"module #{name} registered !"
       else
         p "registration error", res.to_str
        end
         url="http://gs2.mapper-project.eu:1234/add_implementation/Submodel/#{name}/"
         params_array=create_array_params(params)
         config=determine_configuration_file implementation_type, execution
         interpreter=determine_interpreter(implementation_type)[0]
         version=determine_interpreter(implementation_type)[1]
         if (implementation_type==:muscle_kernel)
            res=RestClient.post url, {"interpreter"=>interpreter,"int_version"=>version,"bundle_location"=>"#{$jar_final_location}/#{name.downcase}.jar","class"=>"mask.example.#{name}", "parameters[]"=>params_array  }
         else
            res=RestClient.post url, {"interpreter"=>interpreter,"int_version"=>version,"config_file"=>config, "parameters[]"=>params_array  }
         end
     p res.to_str
   
    else
      p "------------junction--------------"
      array_ports=create_ports_array(ports)
      res= RestClient.post 'http://gs2.mapper-project.eu:1234/add_base/Junction', {"id"=>"#{name}", "name"=>"#{name}", "type"=>junctiontype.to_s,
                 "ports[]"=>array_ports}
      if (res.code==200)
         p"juction #{name} registered !"
      else
         p "registration error", res.to_str
      end
      url="http://gs2.mapper-project.eu:1234/add_implementation/Junction/#{name}/"
         
         params_array=create_array_params(params)
         config=determine_configuration_file implementation_type, execution
         interpreter=determine_interpreter(implementation_type)[0]
         version=determine_interpreter(implementation_type)[1]

         if (implementation_type==:muscle_kernel)
            res=RestClient.post url, {"interpreter"=>interpreter,"int_version"=>version,"bundle_location"=>"#{$jar_final_location}/#{name.downcase}.jar","class"=>"mask.example.#{name}", "parameters[]"=>params_array  }
         else
           
            res=RestClient.post url, {"interpreter"=>interpreter,"int_version"=>version,"config_file"=>config, "parameters[]"=>params_array  }
         end
         
if (res.code==200)
         p"implementation of juction #{name} registered !"
       else
         p "registration error", res.to_str
        end
         p res.to_str
    end
    #p "Name " +  name
   
   # p "timescale:"
   # p timescale
    #  p "spacescale:"
     # p spacescale
    #unless (junctiontype.nil?)
     # p "juction_type #{junctiontype}"
    #end
    #  p "Ports:"
   # p ports
    #p "Parameters:"
   # p params
  end
end
class Snippet_Generator
  def generate (main_name,my_model,execution)
    model_name=my_model.name

    _model_name_capital=model_name.to_s.capitalize
    _dir_name="generatedExamples"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)
	  _dir_name+="/#{main_name}"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)
	  _dir_name+="/snippets"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)

     	open("#{_dir_name}/#{_model_name_capital}.snipet", 'w') { |f|
            execution.each do |element|
             
              if (element[0]==:execute)
                f.puts element[1]
              end
            end
           f.close
        }
     p "kernel #{_model_name_capital} generated"
  end
end

class Muscle_Generator
 def generate_kernel (main_name, my_model, declarations, execution, params)
       # @generated_kernels||=[]
       # @generated_kernels.push instance_name

   model_name=my_model.name
   model_extra_imports=my_model.extra_imports
   timescale=my_model.timescale
   spacescale=my_model.spacescale
     	_model_name_capital=model_name.to_s.capitalize
	_dir_name="generatedExamples"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
	_dir_name+="/#{main_name}"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
	_dir_name+="/src"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
	_dir_name+="/mask"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
	_dir_name+="/example"
        Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
     	open("#{_dir_name}/#{_model_name_capital}.java", 'w') { |f|
        @my_file=f
     		generate_prefix _model_name_capital, model_extra_imports
     		generate_ports declarations 
     		generate_get_scale timescale, spacescale
        generate_execution_begin
     		generate_execution_declarations model_name, declarations, params
     		generate_execution_body declarations, execution, 1
     		generate_end 
         f.close
        }
    p "kernel #{_model_name_capital} generated"
 end

 def generate_prefix instance_name, model_extra_imports
   @my_file.puts "

package mask.example;

import muscle.core.CxADescription;
import muscle.core.ConduitExit;
import muscle.core.ConduitEntrance;
import muscle.core.Scale;
import muscle.core.kernel.RawKernel;
import java.math.BigDecimal;
import javax.measure.DecimalMeasure;
import javax.measure.quantity.Duration;
import javax.measure.quantity.Length;
import javax.measure.unit.SI;
"
unless model_extra_imports.nil?
  @my_file.puts "import #{model_extra_imports};"

end

  @my_file.puts "

/**
a simple java example kernel generated from MASK skeleton
*/
public class #{instance_name} extends muscle.core.kernel.CAController {
"
 end


 def generate_ports declarations
   if (!declarations.nil?)
    declarations.each_key do |name|
      if declarations[name][0]==:double_array
       if declarations[name][2]==:send
          @my_file.puts "\tprivate ConduitEntrance<double[]> #{name}pipe;"        
       end
       if declarations[name][2]==:receive
          @my_file.puts "\tprivate ConduitExit<double[]> #{name}pipe;"        
       end
      end
    end  
    @my_file.puts " "
    @my_file.puts "\tprotected void addPortals(){"

      declarations.each_key do |name|
        if declarations[name][0]==:double_array
          if declarations[name][2]==:send
            @my_file.puts "\t\t#{name}pipe= addEntrance(\"#{name}\",1, double[].class);"
          end
          if declarations[name][2]==:receive
            @my_file.puts  "\t\t#{name}pipe= addExit(\"#{name}\",1, double[].class);"
          end
        end
    end  

    @my_file.puts "	}"

   end 
 end
 def generate_get_scale time_scale, space_scale
   @my_file.puts "
\tpublic muscle.core.Scale getScale() {
\t\tjavax.measure.DecimalMeasure dt = javax.measure.DecimalMeasure.valueOf(new java.math.BigDecimal(1), javax.measure.unit.SI.SECOND);
\t\tjavax.measure.DecimalMeasure dx = javax.measure.DecimalMeasure.valueOf(new java.math.BigDecimal(1), javax.measure.unit.SI.METER);
\t\treturn new Scale(dt,dx);
\t}
"
 end
 def generate_get_scale_full time_scale, space_scale

   @my_file.puts "
\tpublic muscle.core.Scale getScale() {
"

   
#p "timescale#{time_scale}"
    unless (time_scale.nil?)
        @my_file.puts "
    \t\tDecimalMeasure<Duration> dt = DecimalMeasure.valueOf(new BigDecimal(#{time_scale[:delta]}), SI.SECOND);
    "
    end
    unless (space_scale.nil?)
        string_for_scale_constructor="";
        space_scale.each do |scale|
            @my_file.puts "\t\tDecimalMeasure<Length> d#{scale[:id]} = DecimalMeasure.valueOf(new BigDecimal(#{scale[:delta]}), SI.METER);"
            string_for_scale_constructor=string_for_scale_constructor+" d#{scale[:id]}, "
        end
        
        @my_file.puts " \t\treturn new Scale(dt, #{string_for_scale_constructor.chomp(", ")} );"
        
       else
         unless (time_scale.nil?)
          @my_file.puts " \t\treturn new Scale(dt);"
         end
    end

 if (time_scale.nil? && space_scale.nil?)
    @my_file.puts "\t return null;"
 end
  @my_file.puts "
       \t}
    "

 end
def generate_execution_begin
      @my_file.puts "\tprotected void execute(){
  \t\tString myName= getKernelBootInfo().getName();    
  "

    
end
 def generate_execution_declarations model_name, declarations, params


    unless (params.nil?)
        params.each_key do |name|
          unique_key="myName+\":#{name}\""
          case (params[name])
           when Integer
             #@my_file.puts "\t\tint #{name} = #{params[name]};"

             @my_file.puts "\t\tint #{name} = CxADescription.ONLY.getIntProperty(#{unique_key});"
           when Float
            # @my_file.puts "\t\tdouble #{name} = #{params[name]};"
             @my_file.puts "\t\tdouble #{name} = CxADescription.ONLY.getDoubleProperty(#{unique_key});"
          when  String
            @my_file.puts "\t\tString #{name} = CxADescription.ONLY.getProperty(#{unique_key});"
          else
            p "Unrecognized type of parameter for #{name}"
          end

        end
   end
   if (!declarations.nil?)
        declarations.each_key do |name|
          if (declarations[name][0]==:double_array)
           if declarations[name][2]==:send
              @my_file.puts "\t\tdouble[] #{name} = new double[#{declarations[name][1]}];"
           end
           if declarations[name][2]==:receive
              @my_file.puts "\t\tdouble[] #{name} = null;"
           end
          end
        end
       end
 end

 def generate_execution_body(declarations, execution_a, deep)
   if (!execution_a.nil?)
      execution_array=execution_a.clone
      while !execution_array.empty? do
        @token=execution_array.shift
        if (@token[0]==:receive)
          if (declarations[@token[1]][0]!=:file)
            @my_file.puts "\t"*(deep+1)+"#{@token[1]}=#{@token[1]}pipe.receive();"
          end
        end
        if (@token[0]==:send)
          if (declarations[@token[1]][0]!=:file)
            @my_file.puts "\t"*(deep+1)+"#{@token[1]}pipe.send(#{@token[1]});"
          end
         end
        if (@token[0]==:execute)
          @ext_code=@token[1].gsub("\n", "\n"+"\t"*(deep+1))
          @my_file.puts "\t"*(deep+1)+"#{@ext_code}"
        end
        if (@token[0]==:loop)
          # TODO - unique maskIterator !
          @my_file.puts "\t"*(deep+1)+"for (int maskIterator=#{@token[1][:start_time]}; maskIterator<#{@token[1][:stop_time]}; maskIterator+=#{@token[1][:step_time]}){"
          generate_execution_body declarations, @token[2],  deep+1
          @my_file.puts "\t"*(deep+1)+"}"
        end
      end
   end
 end

 def generate_end
  @my_file.puts "\t}"
  @my_file.puts "}"
 end

def generate_build_xml main_name, name, instances

  _dir_name="generatedExamples"
   Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
  _dir_name+="/#{main_name}"
  Dir.mkdir(_dir_name) unless File.directory?(_dir_name) 
  
  text = File.read("build.xml_template")
  text.gsub!("MaskExample1", "#{name}")
  text.gsub!("maskExample1.jar", "#{name.downcase}.jar")
  text.gsub!("JARDESTINATIONDIR","#{$jar_destination_dir}")
  build_jar_string=""
  build_copy_string=""
  unless instances.nil?
  instances.each_key do |name|
    build_jar_string=build_jar_string+"
    <jar destfile=\"build/#{instances[name][0].to_s.downcase}.jar\">
    <fileset dir=\"classes\">
          <include name=\"mask/example/#{instances[name][0].to_s.capitalize}.class\"/>
    </fileset>

  </jar>
      "
   build_copy_string=build_copy_string+"
<copy file=\"build/#{instances[name][0].to_s.downcase}.jar\" todir=\"#{$jar_destination_dir}\" />
"
    
	 end
  
else
  build_jar_string="
  <jar destfile=\"build/#{name.to_s.downcase}.jar\">
    <fileset dir=\"classes\">
          <include name=\"mask/example/*\"/>
    </fileset>

  </jar>

  "
  build_copy_string="
<copy file=\"build/#{name.to_s.downcase}.jar\" todir=\"#{$jar_destination_dir}\" />
  "
  end
  build_jar_string=build_jar_string+"
  <mkdir dir=\"#{$jar_destination_dir}\" />"+ build_copy_string
  

  text.gsub!("INSERTJAR",build_jar_string)
  
  
  File.open("generatedExamples/#{main_name}/build.xml", "w") {|file| file.puts text}
    

end

def generate_cxa (main_name, params,  instances, connection_scheme)

  _dir_name="generatedExamples"
   Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
  _dir_name+="/#{main_name}"
  Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        
  _dir_name+="/cxa"
  Dir.mkdir(_dir_name) unless File.directory?(_dir_name)        

  open("#{_dir_name}/#{main_name}.cxa.rb", 'w') { |f|
    class_path_string=""
   instances.each_key do |name|
    #p instances[name]
    class_path_string=class_path_string+"#{$jar_destination_dir}/#{instances[name][0].to_s.downcase}.jar:"
	 end

    f.puts "

# configuration file for a MUSCLE CxA
abort \"this is a configuration file for to be used with the MUSCLE bootstrap utility\"   if __FILE__ == $0

# add build for this cxa to system paths (i.e. CLASSPATH)
m = Muscle.LAST
m.add_classpath \"#{class_path_string}\"

# configure cxa properties
cxa = Cxa.LAST

cxa.env[\"cxa_path\"] = File.dirname(__FILE__)
"

  
  f. puts "
# declare kernels
"
 
   instances.each_key do |name|
    #p instances[name]
    f.puts "cxa.add_kernel('#{name}', \"mask.example.#{instances[name][0].to_s.capitalize}\")"
	 end


     f. puts "
# parameters
"
   unless (params.nil?)
   params.sort.each do |name|
    if (name[1].is_a?(String))
     f.puts "cxa.env[\"#{name[0]}\"]=\"#{name[1]}\""
    else
    f.puts "cxa.env[\"#{name[0]}\"]=#{name[1]}"
    end
   end
	end
  

	f.puts "
# configure connection scheme
cs = cxa.cs
"

 connection_scheme.each do |connection|
     
       kernel1=connection[0]
       kernel2=connection[1]
       f.puts "cs.attach('#{kernel1}' =>'#{kernel2}' ) {"
       connection[2].each do |tied_ports|
            f.puts "tie('#{tied_ports[0]}', '#{tied_ports[1]}')"
       end
       f.puts "}"
   end


  }

end
end


if ARGV.size > 0
  load ARGV.shift
else
  puts "Usage: ruby mask.rb filename"
end

