require 'json'
require 'net/http'
require 'httpclient'

placeFilename = ARGV[0]
apiKey = ARGV[1]

if placeFilename == nil || apiKey == nil
	puts "Usage: ruby getPlaces.rb filename apiKey"
	exit
end


data = JSON.parse(File.read(placeFilename))
array = data[data.keys[0]]

array.each do |place|
	placeId = place["place_id"]
	if placeId == nil && place["extra"] != nil
		placeId = place["extra"]["place_id"]
	end

	if placeId != nil
		url = "https://maps.googleapis.com/maps/api/place/details/json?key=#{apiKey}&placeid=#{placeId}"
		filename = "_data/places/#{placeId}.json"

		puts url

		clnt = HTTPClient.new;
		data = clnt.get_content(url)
		result = JSON.parse(data)
		result["result"]["opening_hours"].delete("open_now")

		File.open(filename,"w") do |f|
  			f.write(JSON.pretty_generate(result))
		end
	end
end

files = Dir["./_data/places/**/*.json"]

allHours = Hash.new

files.each do |f|
	result = JSON.parse(File.read(f))
	hours = result["result"]["opening_hours"]
	key = f.split('/')[-1].sub(".json","")
	allHours[key] = hours
end

File.open("_data/allHours.json","w") do |f|
  		f.write(JSON.pretty_generate(allHours))
	end