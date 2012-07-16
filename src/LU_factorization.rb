# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'drb'
require "net/http"
require "uri"
require 'rest_client'
require 'linalg'
require 'drb'
include Linalg

class Calculating_object

  def initialize cpu_quard_url, my_id, resman_uri

    @my_id=my_id.to_i
    @cpu_quard=DRbObject.new nil, cpu_quard_url
    @resman= DRbObject.new nil, resman_uri
  end

  def calculate

    beginning = Time.now
    a = DMatrix.rand(1600, 1600)
    l, u = a.lu
    File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("Time elapsed #{Time.now - beginning} seconds\n")}
    puts  "Time elapsed #{Time.now - beginning} seconds\n"
  end
  def spawn filename


    _factory_port=@resman.get_resources 2

     _url="http://localhost:#{_factory_port}"
      puts _url
     res= RestClient.post "http://localhost:#{_factory_port}/filename/#{filename}", ""
     puts res
    
  end
  def process
   # puts "processing"
    #Thread.new do

      3.times do
       # puts "getting permissions"
         @cpu_quard.get_permission(@my_id)
         calculate
         @cpu_quard.release_permission(@my_id)
         spawn "finegrained.rb"
      end
   # end
     File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("koniec\n")}
     puts  "koniec\n"
     #STDOUT.flush
  end
end
#puts ARGV[0], ARGV[1]
Calculating_object.new(ARGV[0], ARGV[1], ARGV[2]).process

#exit(0)