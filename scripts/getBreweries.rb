require 'json'
require 'net/http'
require 'httpclient'

ACCESS_TOKEN = ARGV[0]
SECRET = ARGV[1]

if ACCESS_TOKEN == nil || SECRET == nil
	puts "Usage: ruby buildExtra.rb UNTAPPED_ID UNTAPPED_SECRET"
	exit
end

files = Dir["./untappd/beer/**/*.json"]

files.each do |file|
	data = JSON.parse(File.read(file))

	brewery = data["response"]["beer"]["brewery"]
	id = brewery["brewery_id"]
	filename = "untappd/brewery/" + id.to_s + ".json"
	if(File.file?(filename))
		puts "skip " + id.to_s
	else
		puts "fetch " + id.to_s
		url = "https://api.untappd.com/v4/brewery/info/" + id.to_s + "?client_id=" + ACCESS_TOKEN + "&client_secret=" + SECRET

		puts url

		clnt = HTTPClient.new;
		data = clnt.get_content(url)
		result = JSON.parse(data)
		result["response"]["brewery"]["media"] = nil
		result["response"]["brewery"]["checkins"] = nil
		result["response"]["brewery"]["beer_list"] = nil

		File.open(filename,"w") do |f|
  			f.write(JSON.pretty_generate(result))
		end
		sleep(4)
	end
end