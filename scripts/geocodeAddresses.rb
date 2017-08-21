require 'json'
require 'geocoder'

def updateCoords(filename,key)
	data = JSON.parse(File.read(filename))
	places = data[key]
	places.each do |p|
		loc = p["location"]
		puts loc["address"]
		if loc["address"].length >0 && loc["lat"] == nil
			result = Geocoder.search(loc["address"])
			if result.count > 0
				loc["lat"] = result[0].latitude
				loc["lng"] = result[0].longitude
			else 
				puts "Error for " + loc["address"]
			end
			
		end
	end

	File.open(filename,"w") do |f|
  		f.write(JSON.pretty_generate(data))
	end

end

updateCoords("_data/pubs.json","pubs")
updateCoords("_data/bottleshops.json","shops")
updateCoords("_data/breweries.json","breweries")

