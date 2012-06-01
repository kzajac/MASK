# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'linalg'
require 'drb'
include Linalg

class Calculating_object

  def initialize cpu_quard_url, my_id

    @my_id=my_id.to_i
    @cpu_quard=DRbObject.new nil, cpu_quard_url

  end

  def calculate

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
       # puts "getting permissions"
      @cpu_quard.get_permission(@my_id)
         calculate
         @cpu_quard.release_permission(@my_id)
#         pid=spawn(1, datain, dataout,"finegrained.rb")
      end
   # end
     File.open("/home/kzajac/MASK/src/wyniki", 'a') {|f| f.write("koniec\n")}
     puts  "koniec\n"
  end
end
#puts ARGV[0], ARGV[1]
Calculating_object.new(ARGV[0], ARGV[1]).process
exit(0)