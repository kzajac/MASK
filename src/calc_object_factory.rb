#!/usr/bin/env ruby -w
# simple_service.rb
# A simple DRb service

# load DRb
require 'drb'
require 'thread'
require 'rubygems'


require 'sinatra'



class CPU_guard
  attr_accessor :cpuqueue, :calc_queues
  def initialize
    @cpuqueue=Queue.new
    @calc_queues||=[]
  end
 
  def create_communication_channels
   channels={:in=>Queue.new,:out=>Queue.new}
   @calc_queues.push(channels)
   return @calc_queues.length-1
  end
  def get_permission my_id
    # puts "in get permission routine"
    
     #puts "#{my_id} pushes its id to cpuqueue"
     @cpuqueue.push(my_id)

     inqueue=@calc_queues[my_id][:in]
    # puts "#{my_id} waits for permissions"
     inqueue.pop()
  end
  def release_permission my_id
     outqueue=@calc_queues[my_id][:out]
     outqueue.push(:done)
  end
  def process
    Thread.new do
    while true do
     # puts "CPU getting id of calcluating process"
      calc_id=@cpuqueue.pop
     # puts "CPU pushing ok to #{calc_id}"
      @calc_queues[calc_id][:in].push(:ok)
     # puts "CPU waits for caclculations to finish"
       @calc_queues[calc_id][:out].pop()

    end
  end
  end
  
end

class Calc_object_factory
  def initialize 
    #@cpuguard=CPU_guard.new
    
    @cpuguard=CPU_guard.new
    @cpuguard.process
    
    DRb.start_service nil, @cpuguard
    @cpu_uri=DRb.uri
    @resman_uri="druby://ubuntu:47432"
   
  end
  
  
  def create_object filename
    @objects||=[]
    myid=@cpuguard.create_communication_channels
   
    th=Thread.new do
         $stderr.puts "zaczynam #{filename}"
        wasgood=`ruby /home/kzajac/MASK/src/#{filename} #{@cpu_uri} #{myid} #{@resman_uri}`
        File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("skonczylam #{filename} z wynikiem #{wasgood}\n")}
        $stderr.puts "skonczylam #{filename} z wynikiem #{wasgood}"
   end
    
     
  end
  
end

  

class Calculating_object_test
  def initialize cpu_quard, my_id
    
    @data=0
    @my_id=my_id
    @cpu_quard=cpu_quard
   
  end

  def calculate
    @data=@data+1
    sleep rand(@data)
    puts "process nr #{@my_id} processes #{@data}"
  end

  def process
   # puts "processing"
  Thread.new do
      while true do
       # puts "getting permissions"
        @cpu_quard.get_permission(@my_id)
         calculate
         @cpu_quard.release_permission(@my_id)
      end
  end
  end
end

# start up the DRb service

#DRb.start_service ARGV[0], Calc_object_factory.new(ARGV[1])
calc=Calc_object_factory.new()

# We need the uri of the service to connect a client
#$stderr.puts DRb.uri

# wait for the DRb service to finish before exiting
#DRb.thread.join
set :port, ARGV[0]
post '/filename/:id' do
  calc.create_object params[:id].to_s
end
get '/' do
  "Hello world, it's #{Time.now} at the server!"

end