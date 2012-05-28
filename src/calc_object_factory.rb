#!/usr/bin/env ruby -w
# simple_service.rb
# A simple DRb service

# load DRb
require 'drb'
require 'thread'

class CPU_guard
  attr_accessor :cpuqueue, :calc_queues
  def initialize
    @cpuqueue=Queue.new
    @calc_queues||=[]
  end
 
  def create_communication_channels
   channels={:in=>Queue.new,:out=>Queue.new}
   @calc_queues.push(channels)
   return [@calc_queues.length-1,channels]
  end
  def process
    Thread.new do
    while true do
      calc_id=@cpuqueue.pop
      @calc_queues[calc_id][:in].push(:ok)
      @calc_queues[calc_id][:out].pop()

    end
  end
  end
 
end

class Calc_object_factory
  def initialize
    @cpuguard=CPU_guard.new
    @cpuguard.process
  end
  def create_object
    @objects||=[]
    newobj=Calculating_object.new(@cpuguard.cpuqueue,@cpuguard.create_communication_channels)
    newobj.process
    
  end
  
end

  

class Calculating_object
  def initialize cpuqueue, cpu_quard_info
    # TODO schowac kolejki w obiekcie CPUQuard i jego metodach get permission i release permission
    @data=0
    @my_id=cpu_quard_info[0]
    @cpuqueue =cpuqueue
    @inqueue=cpu_quard_info[1][:in]
    @outqueue=cpu_quard_info[1][:out]
  end

  def calculate
    @data=@data+1
    sleep rand(@data)
    puts "process nr #{@my_id} processes #{@data}"
  end

  def process
    Thread.new do
      while true do
        @cpuqueue.push(@my_id)
        @inqueue.pop()
         calculate
        @outqueue.push(:done)
      end
    end
  end
end
puts "hello"
# start up the DRb service
#DRb.start_service nil, Calc_object_factory.new

# We need the uri of the service to connect a client
#puts DRb.uri

# wait for the DRb service to finish before exiting
#DRb.thread.join
