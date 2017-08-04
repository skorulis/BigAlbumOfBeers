require 'rubygems'
require 'json'

breweries = JSON.parse(File.read("_data/breweries.json"))["breweries"]
locations = JSON.parse(File.read("_data/breweryLocations.json"))

breakdowns = Hash.new

breweries.each do |b|
	bId = b["brewery_id"].to_s
	locs = locations[bId] || []
	locs.each do |l|
		list = breakdowns[l]
		if list == nil
			list = []
			breakdowns[l] = list
		end
		list.push(b)
	end

end 

breakdowns.each do |key, value|
	finalObj = Hash.new
	finalObj["breweries"] = value
	File.open("_data/locations/" + key + ".json","w") do |f|
  		f.write(JSON.pretty_generate(finalObj))
	end
end