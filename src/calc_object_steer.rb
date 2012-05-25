#!/usr/bin/env ruby -w
# simple_service.rb
# A simple DRb service

# load DRb
require 'drb'
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
    @objects.push(Calculating_object.new)
    puts @objects.length
    return index=@objects.length-1
  end
  def ask_calculate object_index, loop_index
    @cpuguard.get_permission
    @objects[object_index].calculate loop_index
    @cpuguard.return_permission
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
