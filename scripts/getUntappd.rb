require 'json'
require 'net/http'
require 'httpclient'

ACCESS_TOKEN = ARGV[0]
SECRET = ARGV[1]

maxId = 100000
total = 0

while total < 20 do
	id = rand(maxId) + 1
	filename = "untappd/beer/" + id.to_s + ".json"
	if(File.file?(filename))
		puts "skip " + id.to_s
	else
		puts "fetch " + id.to_s
		url = "https://api.untappd.com/v4/beer/info/" + id.to_s + "?client_id=" + ACCESS_TOKEN + "&client_secret=" + SECRET

		puts url

		clnt = HTTPClient.new;
		data = clnt.get_content(url)
		result = JSON.parse(data)
		result["response"]["beer"]["media"] = nil
		result["response"]["beer"]["checkins"] = nil
		result["response"]["beer"]["similar"] = nil
		result["response"]["beer"]["friends"] = nil
		result["response"]["beer"]["subscribe_status"] = nil

		File.open(filename,"w") do |f|
  			f.write(JSON.pretty_generate(result))
		end
		total = total + 1
		sleep(4)
	end
	
end
