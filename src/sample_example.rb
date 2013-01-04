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



  define_calculations lu_factorization

    beginning = Time.now
    a = DMatrix.rand(1600, 1600)
    l, u = a.lu
    File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("Time elapsed #{Time.now - beginning} seconds\n")}
    puts  "Time elapsed #{Time.now - beginning} seconds\n"
  end
  define_calculations finegrained
    beginning = Time.now
    a = DMatrix.rand(1600, 1600)
    l, u = a.lu
    File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("Time elapsed #{Time.now - beginning} seconds\n")}
    puts  "Time elapsed #{Time.now - beginning} seconds\n"
  end

  def process
   # puts "processing"
    #Thread.new do

      3.times do
         
         lu_factorization
        
         spawn finegrained
      end
   # end
     File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("koniec\n")}
     puts  "koniec\n"
     #STDOUT.flush
  end

