require 'rubygems'
require 'json'
require 'net/http'

files = Dir["./untappd/**/*.json"]

oldList = JSON.parse(File.read("_data/breweries.json"))["breweries"]

breweries = Hash.new

oldList.each do |brewery|
	breweries[brewery["brewery_id"]] = brewery
end


breweryList = []

files.each do |file|
	data = JSON.parse(File.read(file))

	brewery = data["response"]["beer"]["brewery"]
	imageURL = brewery["brewery_label"]
	brewery["image"] = imageURL.split('/')[-1]

	imageFile = "img/brewery/" + imageURL.split('/')[-1]
	if !File.exists?(imageFile)
		puts imageURL

		#response = Net::HTTP.request_head(URI.parse(imageURL))
		#puts = response['content-length']


		imageData = Net::HTTP.get(URI.parse(imageURL))
		puts imageData.length

		if imageData.length < 250
			brewery["image"] = "missing.png"
		else
			File.write(imageFile, imageData)	
		end
		
		sleep(5)
	end

	

	bId = brewery["brewery_id"]
	if breweries[bId] == nil || true
		breweries[bId] = brewery
	end

	

end


breweries.each do |key, value|
  breweryList.push(value)
end

finalObj = Hash.new
finalObj["breweries"] = breweryList

File.open("_data/breweries.json","w") do |f|
  f.write(JSON.pretty_generate(finalObj))
end