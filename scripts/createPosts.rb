require 'json'
require 'slugify'

maxPages = ARGV[0]

allBeers = JSON.parse(File.read('_data/full.json'))
@allBreweries = JSON.parse(File.read('_data/breweries.json'))["breweries"]
stats = JSON.parse(File.read('js/stats.json'))

if maxPages != nil
	allBeers = allBeers.first(maxPages.to_i)
	stats = stats.first(maxPages.to_i)
end

statMap = Hash[stats.map{ |a| [a["name"], a] }]
extraMap = JSON.parse(File.read('js/extra.json'))

breweries = stats.map { |beer| beer["b"]}.uniq.select {|brewery| brewery != nil}
pubs = JSON.parse(File.read("_data/pubs.json"))["pubs"]
shops = JSON.parse(File.read("_data/bottleshops.json"))["shops"]

def clearDir(path)
	Dir.foreach(path) {|f| fn = File.join(path, f); File.delete(fn) if f != '.' && f != '..'}
end

def breweryURL(brewery,breweryId)
	if brewery == "Skorubrew"
		return "http://homebrew.skorulis.com"
	else
		return "https://untappd.com/w/" + brewery.slugify + "/" + breweryId.to_s 
	end
end

def findBreweryDetails(bId)
	@allBreweries.each do |b|
		if b["brewery_id"] == bId
			return b
		end
	end
	return nil
end

def placeFilename(placeName,type)
	date = "2016-11-09-"
	return "/#{type}/" + date + customSlugify(placeName)
end

def customSlugify(text)
	return text.strip.slugify.gsub("-.",".").gsub("---","-").gsub("--","-").gsub(/\-$/, '').gsub("Ø","o")
end

def writeBasicPlace(file,filename,title,type)
	file.puts('---')
	file.puts('layout: brewery')
	file.puts('filename: "' + filename + '"')
	file.puts('title: "' + title.strip + '"')
	file.puts('permalink: /' + type + '/:title.html')
end

def writePlaceLocation(file,details)
	if details["location"] != nil
		file.puts("lat: " + details["location"]["lat"].to_s)
		file.puts("lng: " + details["location"]["lng"].to_s)
	end
end

def writePlaceContact(file,details)
	contact = details["contact"]
	if contact != nil
		if contact["instagram"] != nil
			file.puts("instagram: '" + contact["instagram"] + "'")
		end
		if contact["twitter"] != nil
			file.puts("twitter: '" + contact["twitter"] + "'")
		end
		if contact["facebook"] != nil
			file.puts("facebook: '" + contact["facebook"] + "'")
		end
	end
end

def writePlaceExtra(file,extra)
	if extra["place_id"] != nil
		file.puts("google_place: " + extra["place_id"])
	end
	reviews = extra["reviews"]
	if reviews != nil
		if reviews["beers"] != nil
			file.puts("review_beer: \"" + reviews["beers"] + '"')	
		end
		if reviews["venue"] != nil
			file.puts("review_venue: \"" + reviews["venue"] + '"')	
		end
	end
end

clearDir("_posts/brewery")
clearDir("_posts/beer")
clearDir("_posts/pub")
clearDir("_posts/bottleshop")

breweries.each do |item|
	beerMatch = stats.select {|beer| beer["b"] == item}[0]["name"]
	extra = extraMap[beerMatch]
	untappd = extra["untappd"]
	breweryURL = breweryURL(item,untappd["breweryId"])
	details = findBreweryDetails(untappd["breweryId"])
	
	filename = "_posts" + placeFilename(item,"brewery") + ".md"

	File.open(filename,'w') { |file|
		writeBasicPlace(file,filename,item,"brewery")
		file.puts('breweryURL: "' + breweryURL + '"')
		if details != nil
			details["contact"]["slug"] = "brewery/" + customSlugify(item)
			writePlaceLocation(file,details)
			writePlaceContact(file,details)
			extra = details["extra"]
			if extra != nil
				writePlaceExtra(file,extra)
			end
		end
		
		file.puts('---')
	}
end

pubs.each do |item|
	filename = "_posts" + placeFilename(item["name"],"pub") + ".md"
	item["contact"]["slug"] = "pub/" + customSlugify(item["name"])
	File.open(filename,'w') { |file|
		writeBasicPlace(file,filename,item["name"],"pub")
		writePlaceLocation(file,item)
		writePlaceContact(file,item)
		writePlaceExtra(file,item)
		file.puts('---')
	}
end

shops.each do |item|
	filename = "_posts" + placeFilename(item["name"],"bottleshop") + ".md"
	item["contact"]["slug"] = "bottleshop/" + customSlugify(item["name"])
	File.open(filename,'w') { |file|
		writeBasicPlace(file,filename,item["name"],"bottleshop")
		writePlaceLocation(file,item)
		writePlaceContact(file,item)
		writePlaceExtra(file,item)
		file.puts('---')
	}
end

File.open("_data/pubs.json","w") do |f|
  	f.write(JSON.pretty_generate({"pubs" => pubs}))
end

File.open("_data/bottleshops.json","w") do |f|
  	f.write(JSON.pretty_generate({"shops" => shops}))
end

File.open("_data/breweries.json","w") do |f|
  	f.write(JSON.pretty_generate({"breweries" => @allBreweries}))
end

if maxPages == nil
	File.open("_data/full.json","w") do |f|
  		f.write(JSON.pretty_generate(allBeers))
	end
end