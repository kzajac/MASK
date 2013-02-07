# To change this template, choose Tools | Templates
# and open the template in the editor.


require 'rubygems'

# If you're using bundler, you will need to add this
#require 'bundler/setup'

require 'sinatra'
require 'json'
require 'linalg'
require 'pp'
include Linalg
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

  def self.add id, name, predcessor, iteration
    #TODO: refactor !

   if iteration=="begin"
      @ident="begin"
   elsif iteration=="finish"
     @ident="finish"
   else
    @ident=generate_id
   end

   @calculations||=Hash.new
   @calculations_stack||=[]
   identifier="#{id}_#{@ident}"
   @calculations_stack.push(identifier)
   @calculations[identifier]={"name"=>name, "predcessor"=>predcessor, "status"=> "waiting"}
  
  end
  def self.status_calc identifier
    @calculations[identifier]["status"]
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
    unless identifier.nil?
      if (identifier.include?("finish"))
        @calculations[identifier]["status"]="finished"
        inform_predcessor(@calculations[identifier]["predcessor"])
      elsif (identifier.include?("begin"))
         @calculations[identifier]["status"]="finished"
         init_state_rout

      else
        if (@log.nil?)
          @log = Logger.new(STDOUT)
        end
        @log.level = Logger::DEBUG
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


post '/calculations' do
   

      jdata = params[:data]
      for_json = JSON.parse(jdata)

      name= for_json["name"]
      id= for_json["id"]
      predcessor=for_json["predcessor"]
      iteration=for_json["iteration"]

      Calculations.add(id, name, predcessor, iteration)
     
      body("http://#{request.host}:#{request.port}/calculations/#{id}_#{iteration}")

      status 200
    end
get '/calculations/' do

  body(Calculations.all_statuses.to_json)
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
