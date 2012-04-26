
class DSLElement
 def copyvars
  self.class.instance_variables.each do |var|
   instance_variable_set(var, self.class.instance_variable_get(var))
  end 
 end
end


class Modules <DSLElement

   def self.create(name, &block)
      @my_name=name
      f = Modules.new
      f.class.instance_eval(&block) if block_given?
      f.copyvars
      return f
    end


    def self.app_module (name, &blk)
      @modules||=Hash.new
      klass = Class.new(Mod)
      name_s=name.to_s.capitalize
      Object.const_set(name_s, klass)  unless Object.const_defined?(name_s)
      p = Object.const_get(name_s).new
      p.name=name_s
      p.subname=@my_name
      #p = Mod.new(name.to_s)
      p.class.class_eval(&blk) if block_given?
      p.copyvars
      @modules[name] = p
    end


    def self.execute (name)
      print "-module(#{@my_name.to_s}).
-export(["
      number_modules=@modules.length
      number_cur=0;
      @modules.each_key { |key|
          rep=@modules[key].execution.rep
          if rep<2
            args=0
          else
            args=1
          end
          print "loop#{key.to_s.capitalize}/#{args}"
          number_cur=number_cur+1
          if (number_cur<number_modules)
            print ","
          end
      }
      puts "]).\n"
      @modules.each_key { |key|
          puts "%erlang code generated for module #{key}"
          @modules[key].execute
      }
    end
 end



 class Element < DSLElement
  attr_accessor :name

  def initialize(name=nil)
    @name = name
  end
 end

class Mod < Element
  attr_accessor :subname, :execution

  def initialize(name=nil)
    @name = name
    @subname=nil
    super
  end

  def self.cores(nbcores)
    @cores=nbcores
  end

  def self.execution (rep=1, &blk)
      klass = Class.new(Execution)
      name_s="Exec"+self.name.to_s
      Object.const_set(name_s, klass)  unless Object.const_defined?(name_s)
      p = Object.const_get(name_s).new
      p.class.class_eval(&blk) if block_given?
      p.copyvars
      @execution = p
      @execution.rep=rep
  end

  def execute
    name_s="loop"+@name.to_s
    if (@execution.rep>=2)
           puts "
#{name_s}(0) ->
       io:format(\"~w ending ~n\",[self()]);

#{name_s}(Number) ->
    "
    else
      puts "
#{name_s}() ->
      "
    end
    number_of_commends=@execution.commends.length
    number_cur=0;
    @execution.commends.each {|commend|

      commend.each_key do |commend_symbol|

         #puts commend_symbol
         if commend_symbol==:c
           print "io:format(\"~w calculating~n\",[self()]),\ntimer:sleep(#{commend[commend_symbol]})"
         end

         if commend_symbol==:r
           pid_name=commend[commend_symbol].to_s.capitalize
           print "io:format(\"~w waiting for message ~n\",[self()]),\nreceive \n {#{pid_name}, Msg} -> \n\tio:format(\"~w received ~w~n\",[self(),Msg])\nend"
         end

         if commend_symbol==:e
           pid_name=commend[commend_symbol].to_s.capitalize
           print "io:format(\"~w sending message to ~w~n\",[self(),#{pid_name}]),\n#{pid_name} ! {self(), Msg}"

         end

         if commend_symbol==:s
             pid_name=commend[commend_symbol][:id].to_s.capitalize
             module_name="loop"+commend[commend_symbol][:id].to_s.capitalize

             print "io:format(\"~w spawning ~n\",[self()]), 
#{pid_name} = spawn(#{self.subname}, #{module_name}, []), \n
io:format(\"~w sending data to ~w ~n\",[self(), #{pid_name}]),
#{pid_name} ! {self(), value}"
         end
         number_cur=number_cur+1




         if (number_cur==number_of_commends)
           if (@execution.rep>=2)
            print ",\n#{name_s}(Number-1)."
           else
             print "."
           end
         else
            puts ","
         end
         puts"\n"
     end
     }
  end
end


class Execution <DSLElement
  attr_accessor :commends, :rep

  def self.calculate (nb)
    @commends||=[]
    @commends.push(:c=>nb)
  end

  def self.spawn (sp_hash)
    @commends||=[]
    @commends.push(:s=>sp_hash)
    
    idik=sp_hash[:id].to_s.capitalize
    core_number=sp_hash[:cores]
    calculations_number=sp_hash[:calculate]
    
    Modules.app_module idik do
        cores core_number

        execution 1 do

                   receive idik

                   calculate calculations_number

                   send  idik
          end
    end
  end

  def self.receive(id)
     @commends||=[]
     @commends.push(:r=>id)
  end

  def self.send(id)
     @commends||=[]
     @commends.push(:e=>id)
  end

end
#puts "Hello World"
#if ARGV.size > 0
 # load ARGV.shift
#else
   load  "/home/kzajac/MASK/examples/actordsl.txt"
 # puts "Usage: ruby mask.rb filename"
