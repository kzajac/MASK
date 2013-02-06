require 'rubygems'
    require "rest_client"
    require "json"
   # require 'uri'

    #1: Simple POST
   # res = Net::HTTP.post_form(URI.parse('http://gs2.mapper-project.eu:1234/add_base/Submodel'),
     #{"id"=>"92343", "name"=>'MojModel', "timescale[delta]"=>"10","timescale[max]"=>"100"})
jdata = {:key => 'I am a value'}.to_json
#jdata="Kasia".to_json
puts jdata
res= RestClient.post 'http://localhost:4567/calculations', {:data => jdata}, {:content_type => :json, :accept => :json}
#res= RestClient.post 'http://localhost:4567/calculations', "message"=>"Kasia2"
p res

res= RestClient.get 'http://localhost:4567/calculations/'
p res

#conn = Net::HTTP.new('http://gs2.mapper-project.eu/',1234)
#request = Net::HTTP::Post.new("/add_base/Submodel")
#request.set_form_data({"id"=>"923433", "name"=>'MojModel', "class"=>"my_class", "timescale[delta]"=>"10","timescale[max]"=>"100",
    #   "spacescales[][delta]"=>["20"],"spacescales[][max]"=>"200" })
#res = conn.request(request)
   #res = Net::HTTP.post_form(URI.parse('http://gs2.mapper-project.eu:1234/add_base/Submodel'),
    # {"id"=>"923433", "name"=>'MojModel', "class"=>"my_class", "timescale[delta]"=>"10","timescale[max]"=>"100",
     # "spacescales[][delta]"=>"500", "spacescales[][max]"=>["cos1","cos2"],"scalespaces[][delta]"=>["99","88"] })
 #res = Net::HTTP.post_form(URI.parse('http://gs2.mapper-project.eu:1234/add_base/Submodel'),
    # "id=923433&name=MojModel&class=my_class&timescale[delta]=10&timescale[max]=100")
     #  "spacescales[][delta]"=>"20","spacescales[][max]"=>"300","spacescales[][delta]"=>"30","spacescales[][max]"=>"200" })
  # res = Net::HTTP.post_form(URI.parse('http://gs2.mapper-project.eu:1234/add_base/Submodel'),
    # {"id"=>"9234", "class"=>'jModel2'})
 
    puts res
    