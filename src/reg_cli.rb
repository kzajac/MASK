
    require 'net/http'
    require 'uri'

    #1: Simple POST
    res = Net::HTTP.post_form(URI.parse('http://gs2.mapper-project.eu:1234/add_base/Submodel'),
     {"id"=>9234, "name"=>'MojModel', "timescale"=>{"delta"=>10,"max"=>100}})
 
    puts res
    
