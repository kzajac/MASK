# To change this template, choose Tools | Templates
# and open the template in the editor.


require 'rubygems'

# If you're using bundler, you will need to add this
#require 'bundler/setup'

require 'sinatra'
require 'json'
class Calculations

  def self.init_state_rout
     @state1=0
   end

  def self.calculations_rout
    @state1=@state1+1
    puts @state1
    beginning = Time.now
    a = DMatrix.rand(1600, 1600)
    l, u = a.lu
    File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("Time elapsed #{Time.now - beginning} seconds\n")}
    puts  "Time elapsed #{Time.now - beginning} seconds\n"
    "wynik_obliczen"
  end

  def self.add id, name, predcessor, iteration
   @calculations||=Hash.new
   @calculations_stack||=[]
   identifier="#{id}_#{iteration}"
   @calculations_stack.push(identifier)
   @calculations[identifier]={"name"=>name, "predcessor"=>predcessor, "status"=> "waiting"}

  end
  def self.status_calc identifier
    @calculations[identifier]["status"]
  end
  def self.all_statuses
    return @calculations

  end
  def self.run_calc
    puts "tutaj 2"
    identifier=@calculations_stack.pop unless @calculations_stack.nil?
    put identifier
    @calculations[identifier ]["status"]="running"
    calculations_rout unless identifier.nil?
    @calculations[identifier]["status"]="finished"
  end

 

  

end


Thread.new do
  Calculations.init_state_rout
  while true do
    puts"tutaj"
    puts Calculations.all_statuses
      Calculations.run_calc
      sleep 1
 
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
  body(JSON.pretty_generate({:status=>Calculations.status_calc[params[identifier]]}))
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
