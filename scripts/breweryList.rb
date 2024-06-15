require 'rubygems'
require 'json'
require 'net/http'

files = Dir["./untappd/brewery/**/*.json"]

oldList = JSON.parse(File.read("_data/breweries.json"))["breweries"]

breweries = Hash.new
oldBreweries = Hash.new

oldList.each do |brewery|
	oldBreweries[brewery["brewery_id"]] = brewery
end


breweryList = []

files.each do |file|
	data = JSON.parse(File.read(file))

	brewery = data["response"]["brewery"]
	bId = brewery["brewery_id"]

	old = oldBreweries[bId]
	if old != nil
		brewery = old
	else
		loc = Hash.new
		if brewery["location"]["brewery_address"] != nil
			loc["address"] = brewery["location"]["brewery_address"] + ", " + brewery["location"]["brewery_city"]
		end
	
		loc["lat"] = brewery["location"]["brewery_lat"] 
		loc["lng"] = brewery["location"]["brewery_lng"] 
		brewery["location"] = loc
	end

	imageURL = brewery["brewery_label"]
	brewery["image"] = imageURL.split('/')[-1]
	brewery.delete("brewery_description")
	brewery.delete("media")
	brewery.delete("checkins")
	brewery.delete("beer_list")

	imageFile = "img/brewery/" + imageURL.split('/')[-1]
	if !File.exist?(imageFile)
		puts imageURL

		imageData = Net::HTTP.get(URI.parse(imageURL))
		puts imageData.length

		if imageData.length < 250
			brewery["image"] = "missing.png"
		else
			File.write(imageFile, imageData)	
		end
		
		sleep(1)
	end
	
	breweries[bId] = brewery
	
end


breweries.each do |key, value|
  breweryList.push(value)
end

finalObj = Hash.new
finalObj["breweries"] = breweryList

File.open("_data/breweries.json","w") do |f|
  f.write(JSON.pretty_generate(finalObj))
end