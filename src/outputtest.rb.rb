# To change this template, choose Tools | Templates
# and open the template in the editor.

#puts "Hello World"
#puts `echo TO JA`
    #output = IO.popen("/home/kzajac/MASK/src/LU_factorization.rb #{@cpu_uri} #{myid}")
    #output.readlines

require 'open3'

stdin, stdout, stderr = Open3.popen3('ruby /home/kzajac/MASK/src/LU_factorization.rb')

 puts stdout.readlines

puts stderr.readlines
