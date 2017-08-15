require 'rubygems'
require 'json'

breweries = JSON.parse(File.read("_data/breweries.json"))["breweries"]
pubs = JSON.parse(File.read("_data/pubs.json"))["pubs"]
shops = JSON.parse(File.read("_data/bottleshops.json"))["shops"]
locations = JSON.parse(File.read("_data/breweryLocations.json"))

breakdowns = Hash.new
breakdownPubs = Hash.new
breakdownShops = Hash.new

def addPlace(loc,place,placeHash)
	list = placeHash[loc]
	if list == nil
		list = []
		placeHash[loc] = list
	end
	list.push(place)
end

breweries.each do |b|
	if b["brewery_type"] == "Macro Brewery"
		next
	end
	bId = b["brewery_id"].to_s
	locs = locations[bId] || []
	locs.each do |l|
		addPlace(l,b,breakdowns)
	end
end 

pubs.each do |p|
	locs = locations[p["id"]] || []
	locs.each do |l|
		addPlace(l,p,breakdownPubs)
	end
end

shops.each do |s|
	locs = locations[s["id"]] || []
	locs.each do |l|
		addPlace(l,s,breakdownShops)
	end
end

breakdowns.each do |key, value|
	File.open("_data/locations/" + key + "/breweries.json","w") do |f|
  		f.write(JSON.pretty_generate({"breweries" => value}))
	end
end

breakdownPubs.each do |key, value|
	File.open("_data/locations/" + key + "/pubs.json","w") do |f|
  		f.write(JSON.pretty_generate({"pubs" => value}))
	end
end

breakdownShops.each do |key, value|
	File.open("_data/locations/" + key + "/bottleshops.json","w") do |f|
  		f.write(JSON.pretty_generate({"shops" => value}))
	end
end