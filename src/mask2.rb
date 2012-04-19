
class DSLElement
 def copyvars
  self.class.instance_variables.each do |var|
   instance_variable_set(var, self.class.instance_variable_get(var))
  end 
 end
end


class Modules <DSLElement

   def self.create(&block)
      f = Modules.new
      f.class.instance_eval(&block) if block_given?
      f.copyvars
      return f
    end
    def self.app_module (name, &blk)
      @modules||=Hash.new
      klass = Class.new(Mod)
      name_s=name.to_s
      Object.const_set("B"+name_s, klass)  unless Object.const_defined?("B"+name_s)
      p = Object.const_get("B"+name_s).new
      p.name=name_s
      #p = Mod.new(name.to_s)
      p.class.class_eval(&blk) if block_given?
      p.copyvars
      @modules[name] = p
    end
    def self.execute (name)
      @modules[name].execute
    end
 end
 class Element < DSLElement
 attr_accessor :name

 def initialize(name=nil)
  @name = name
 end
end
class Mod < Element
  def initialize(name=nil)
    @name = name
    super
  end
  def self.cores(nbcores)
    @cores=nbcores
  end

  def self.execution (&blk)
      klass = Class.new(Execution)
      name_s=@name.to_s
      Object.const_set("E"+name_s, klass)  unless Object.const_defined?("E"+name_s)
      p = Object.const_get("E"+name_s).new
      p = Execution.new
      p.class.class_eval(&blk) if block_given?
      p.copyvars
      @execution = p


  end
  def execute
    puts @name
    puts @cores
    puts @execution
    @execution.commends.each {|value| puts "#{value}" }
  end
end
class Execution <DSLElement
  attr_accessor :commends
  def self.calculate (nb)
    @commends||=[]
    @commends.push(:c=>nb)
  end
  def self.spawn (hash)
     @commends||=[]
    @commends.push(:s=>hash)
  end
  def self.receive(id)
     @commends||=[]
    @commends.push(:r=>id)
  end
end
#puts "Hello World"
#if ARGV.size > 0
 # load ARGV.shift
#else
   load  "/home/kzajac/MASK/examples/actordsl.txt"
 # puts "Usage: ruby mask.rb filename"
