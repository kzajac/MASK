# To change this template, choose Tools | Templates
# and open the template in the editor.


require 'rubygems'

# If you're using bundler, you will need to add this
#require 'bundler/setup'

require 'sinatra'
require 'json'
require 'linalg'
require 'pp'
require 'logger'
include Linalg
class Spawns
  def self.add(id)
    @spawns||=Hash.new
    @spawns[id]=[]
    @spawns[id].push("1")
    @spawns[id].length-1
  end
  def self.delete(id)
    _myspawn=@spawns[id] unless @spawns.nil?
    _myspawn.shift unless _myspawn.nil?
    puts ("deleting spawn")
  end
  def self.all_statuses
    return @spawns

  end
end

class Calculations

  def self.init_state_rout
     @state1=0
   end

  def self.calculations_rout
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG

    @state1=@state1+1
    @log.debug("stan=#{@state1}")
    beginning = Time.now
    a = DMatrix.rand(1600, 1600)
    l, u = a.lu
    File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("Time elapsed #{Time.now - beginning} seconds\n")}
    @log.info("Time elapsed #{Time.now - beginning} seconds\n")
  end

  def self.generate_id
    if @gen.nil?
      @gen=0
    else
      @gen=@gen+1
    end
    @gen
  end

  def self.add  name, predcessor, iteration
    #TODO: reactor !

   @calculations||=[]
   @calculations_stack||=[]
   @calculation_instances||=[]


   @calculations.push({"name"=>name, "predcessor"=>predcessor,"iteration"=>iteration, "status"=> "waiting"})
   myind=@calculations.length-1
   @calculations_stack.push(myind)
   return myind

  end
  
  def self.all_statuses
    return @calculations

  end
  
  def self.inform_predcessor pred
    puts "informing predcessor #{pred}"
  end

  def self.get_next_to_process
    @calculations_stack||=[]
    @calculations_stack.shift
  end
  
  def self.run_calc

    identifier=get_next_to_process

    if(@log.nil?)
        @log = Logger.new(STDOUT)
        @log.level = Logger::DEBUG
    end
    
    
    unless identifier.nil?
      iteration=@calculations[identifier]["iteration"]
      if (iteration=="finish")
        @log.debug("finish id=#{identifier}")
        @calculations[identifier]["status"]="finished"
        inform_predcessor(@calculations[identifier]["predcessor"])
      elsif (iteration=="begin")
        @log.debug("begin id=#{identifier}")
         @calculations[identifier]["status"]="finished"
         init_state_rout

      else
        
        @log.debug("licze #{identifier}")
        @calculations[identifier]["status"]="running"
        calculations_rout
        @calculations[identifier]["status"]="finished"
      end
    
    else
      sleep 0.5
    end
  end

 

  

end



Thread.new do
  begin

    while true do
    
      Calculations.run_calc
    
    end
  rescue
      pp $!
  end
end

post '/spawns' do
     jdata=params[:data]
     for_json= JSON.parse(jdata)

     name= for_json["id"]

     myind=Spawns.add(name)

     body("http://#{request.host}:#{request.port}/spawns/#{myind}")

     status 200

end

delete '/spawns' do
     jdata=params[:data]
     for_json= JSON.parse(jdata)

     id= for_json["id"]

     Spawns.delete(id)
     body("deleted")

     status 200
end
post '/calculations' do
   

      jdata = params[:data]
      for_json = JSON.parse(jdata)

      name= for_json["name"]
      predcessor=for_json["predcessor"]
      iteration=for_json["iteration"]

      myind=Calculations.add(name, predcessor, iteration)
     
      body({"index"=>myind, "url"=>"http://#{request.host}:#{request.port}/calculations/#{myind}"}.to_json)

      status 200
    end
get '/calculations/' do

  body(Calculations.all_statuses.to_json)
   status 200
end
get '/spawns/' do

  body(Spawns.all_statuses.to_json)
   status 200
end
get '/calculations/:identifier' do
  
  status 200

  #if Calculations.calculations[params[:number].to_i].nil?
  #  body({:status=>:deleted}.to_json)
  #  status 200
 # else
  #  puts params[:number].to_i
  #  body({:status=>:running, :vales=>Calculations.calculations[params[:number].to_i].to_json}.to_json)
   # status 200
 #end
end
