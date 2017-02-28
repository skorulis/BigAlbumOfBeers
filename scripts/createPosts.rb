require 'json'
require 'slugify'

file = File.read('_data/raw.json')
allBeers = JSON.parse(file)
stats = JSON.parse(File.read('js/stats.json'))
statMap = Hash[stats.map{ |a| [a["name"], a] }]
extraMap = JSON.parse(File.read('js/extra.json'))

breweries = stats.map { |beer| beer["b"]}.uniq.select {|brewery| brewery != nil}

def clearDir(path)
	Dir.foreach(path) {|f| fn = File.join(dir_path, f); File.delete(fn) if f != '.' && f != '..'}
end

def breweryURL(brewery,breweryId)
	if brewery == "Skorubrew"
		return "http://homebrew.skorulis.com"
	else
		return "https://untappd.com/w/" + brewery.slugify + "/" + breweryId.to_s 
	end
end

def breweryFilename(brewery)
	date = "2016-11-09-"
	return "/brewery/" + date + customSlugify(brewery)
end

def customSlugify(text)
	return text.slugify.gsub("---","-").gsub("--","-")
end

breweries.each do |item|
	beerMatch = stats.select {|beer| beer["b"] == item}[0]["name"]
	extra = extraMap[beerMatch]
	untappd = extra["untappd"]
	breweryURL = breweryURL(item,untappd["breweryId"])
	
	filename = "_posts" + breweryFilename(item) + ".md"

	File.open(filename,'w') { |file|
		file.puts('---')
		file.puts('layout: brewery')
		file.puts('filename: "' + filename + '"')
		file.puts('title: "' + item + '"')
		file.puts('breweryURL: "' + breweryURL + '"')
		file.puts('permalink: /brewery/:title.html')
		file.puts('---')
	}
end

allBeers.each do |item|
	date = "2016-11-09-"
	name = item["name"]
	filename = "_posts/beer/" + date + customSlugify(name) + ".md"
	stat = statMap[name]
	extra = extraMap[name]
	brewery = stat["b"]
	country = stat["c"]
	style = stat["style"]
	untappd = extra["untappd"]

	untappdURL = untappd["url"]

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