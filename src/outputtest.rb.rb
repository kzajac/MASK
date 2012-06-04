# To change this template, choose Tools | Templates
# and open the template in the editor.

#puts "Hello World"
#puts `echo TO JA`
    #output = IO.popen("/home/kzajac/MASK/src/LU_factorization.rb #{@cpu_uri} #{myid}")
    #output.readlines


 filename="LU_factorization.rb"
    $stderr.puts "zaczynam #{filename}"
    #th=Thread.new do
        wasgood=`ruby /home/kzajac/MASK/src/#{filename} 7777 1 `

    #end
     #th.join
     $stderr.puts "skonczylam #{filename} z wynikiem #{wasgood}"