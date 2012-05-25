#!/usr/bin/env ruby -w
# simple_service.rb
# A simple DRb service

# load DRb
require 'drb'
require 'thread'

class CPU_guard
  def get_permission
      puts "getting permissions"
  end
  def return_permission
      puts "return permissions"
  end
end

class Calc_object_steer
  def initialize 
    @cpuguard=CPU_guard.new
  end
  def create_object
    @objects||=[]
    newobj=Calculating_object.new
    calcp=Calc_processor.new(newobj)
    @objects.push(calcp)
    calcp.process
    puts @objects.length
    return index=@objects.length-1
  end
  def ask_calculate object_index, loop_index
   
    @objects[object_index].inqueue.push loop_index
    
  end
end
class Calc_processor
  attr_accessor :inqueue
  def initialize (mobj)
    @my_obj=mobj
    @inqueue=Queue.new
    @outqueue=Queue.new
  end
  def process
    Thread.new do
      while true do
        args=@inqueue.pop
        @my_obj.calculate args
        @outqueue.push(:done)
      end
    end
  end
end
class Calculating_object
  def initialize
    @data=0
  end
  def calculate (iter_number)
    @data=@data+1
    puts @data
  end
  def send url
    # send @data 
  end
end
# start up the DRb service
DRb.start_service nil, Calc_object_steer.new

# We need the uri of the service to connect a client
puts DRb.uri

# wait for the DRb service to finish before exiting
DRb.thread.join
