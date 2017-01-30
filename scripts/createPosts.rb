require 'json'
require 'slugify'

file = File.read('_data/raw.json')
allBeers = JSON.parse(file)
stats = JSON.parse(File.read('js/stats.json'))
statMap = Hash[stats.map{ |a| [a["name"], a] }]
extraMap = JSON.parse(File.read('js/extra.json'))

allBeers.each do |item|
	date = "2016-11-09-"
	name = item["name"]
	filename = "_posts/beer/" + date + name.slugify + ".md"
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

		if untappdURL
			file.puts('untappd: "' + untappdURL + '"')
		end

		if country
			file.puts('country: "' + country + '"')
		end
		
		if brewery
			if brewery == "Skorubrew"
				breweryURL = "http://homebrew.skorulis.com"
			else
				breweryURL = "https://untappd.com/w/" + brewery.slugify + "/" + untappd["breweryId"].to_s 
			end
			
			file.puts('brewery: "' + brewery + '"')
			file.puts('breweryURL: "' + breweryURL + '"')
		end
		if style
			file.puts('style: "' + style + '"')
		end

		file.puts('score: ' + item["score"])
		file.puts('img: ' + item["img"])
		file.puts('beer-date: ' + item["date"])
		file.puts('desc: "' + item["desc"] + '"')
		file.puts('permalink: /beer/:title.html')
		file.puts('---')
	}

end