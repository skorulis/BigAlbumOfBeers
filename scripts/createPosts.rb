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

def breweryFilename(brewery)
	date = "2016-11-09-"
	return "/brewery/" + date + customSlugify(brewery)
end

def customSlugify(text)
	return text.slugify.gsub("-.",".").gsub("---","-").gsub("--","-").gsub(/\-$/, '').gsub("Ø","o")
end

clearDir("_posts/brewery")
clearDir("_posts/beer")
clearDir("_posts/bar")
clearDir("_posts/bottleshop")

breweries.each do |item|
	beerMatch = stats.select {|beer| beer["b"] == item}[0]["name"]
	extra = extraMap[beerMatch]
	untappd = extra["untappd"]
	breweryURL = breweryURL(item,untappd["breweryId"])
	details = findBreweryDetails(untappd["breweryId"])
	
	filename = "_posts" + breweryFilename(item) + ".md"

	File.open(filename,'w') { |file|
		file.puts('---')
		file.puts('layout: brewery')
		file.puts('filename: "' + filename + '"')
		file.puts('title: "' + item + '"')
		file.puts('breweryURL: "' + breweryURL + '"')
		file.puts('permalink: /brewery/:title.html')
		if details != nil
			if details["location"] != nil
				file.puts("lat: " + details["location"]["lat"].to_s)
				file.puts("lng: " + details["location"]["lng"].to_s)
			end
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
			if details["extra"] != nil && details["extra"]["place_id"] != nil
				file.puts("google_place: " + details["extra"]["place_id"])
			end
		end
		
		file.puts('---')
	}
end

allBeers.each do |item|
	date = "2016-11-09-"
	name = item["name"]
	filename = "_posts/beer/" + date + customSlugify(name) + ".md"
	fileurl = "/beer/" + customSlugify(name) + ".html"
	stat = statMap[name]
	extra = extraMap[name]
	brewery = stat["b"]
	country = stat["c"]
	style = stat["style"]
	untappd = extra["untappd"]

	untappdURL = untappd["url"]
	item["filename"] = fileurl

	File.open(filename,'w') { |file|
		file.puts('---')
		file.puts('layout: beer')
		file.puts('filename: ' + filename)
		file.puts('title: ' + name)
		file.puts('category: beer')

		if untappdURL
			file.puts('untappd: "' + untappdURL + '"')
		end

		if country
			file.puts('country: "' + country + '"')
		end
		
		if brewery
			breweryURL = "/brewery/" + customSlugify(brewery) + ".html"
			
			file.puts('brewery: "' + brewery + '"')
			file.puts('breweryURL: "' + breweryURL + '"')
		end
		if style
			file.puts('style: "' + style + '"')
		end

		file.puts('score: ' + item["score"])
		file.puts('img: ' + item["img"])
		file.puts('beer-date: "' + item["date"] + '"')
		file.puts('desc: "' + item["desc"] + '"')
		file.puts('permalink: /beer/:title.html')
		file.puts('---')
	}

end

if maxPages == nil
	File.open("_data/full.json","w") do |f|
  		f.write(JSON.pretty_generate(allBeers))
	end
end