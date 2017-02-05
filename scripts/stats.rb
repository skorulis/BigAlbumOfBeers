require 'rubygems'
require 'json'
require 'Date'

allBeers = JSON.parse(File.read('js/raw.json'))
extraInfo = JSON.parse(File.read('js/extra.json'))

ratings = Hash.new
untappdRatings = Hash.new
words = Hash.new
countries = Hash.new
breweries = Hash.new
scoreDiffs = 0
scoreDiffCount = 0
stats = Array.new
countryMapping = Hash.new
countryMapping["England"] = "United Kingdom";
countryMapping["Scotland"] = "United Kingdom";
countryMapping["China / People's Republic of China"] = "China";
countryMapping["Russia"] = "Russian Federation";

def increment(hash,key)
	if key != nil && key.length > 0
		if hash.has_key?(key)
			hash[key] = hash[key] + 1
		else
			hash[key] = 1
		end
	end
end

for x in 0..10
	ratings[x] = 0
	untappdRatings[x] = 0
end
withoutRatings = Array.new
missingPct = Array.new
missingExtra = Array.new
missingUntappdId = Array.new

allBeers.each do |item|
	stat = Hash.new

	name = item["name"]

	stat["name"] = name;
	stat["d"] = item["date"]
	stat["r"] = item["desc"].gsub(' ','').length

	if item["score"] == "null"
		withoutRatings.push(name)
	else
		s = item["score"].to_f;
		stat["score"] = s
	end
	
	nameWords = name.split
	nameWords.each do |w|
		if !words.has_key?(w)
			words[w] = 0
		end
		words[w] = words[w] + 1
	end

	extra = extraInfo[name]
	untappd = extra["untappd"]
	homebrew = extra["homebrew"]
	if extra == nil
		missingExtra.push(name)
	end

	if item["pct"] != "null"
		stat["pct"] = item["pct"].to_f
	elsif untappd["abv"] && untappd["abv"] != 0
		stat["pct"] = untappd["abv"]
	end

	if !stat["pct"]
		missingPct.push(name)
	end
	
	if untappd["id"].length == 0 && !homebrew
		puts name
		missingUntappdId.push(name)
	end
	
	country = untappd["country"]
	if !country && homebrew
		country = homebrew["country"]
	end

	style = untappd["style"]
	if !style && homebrew
		style = homebrew["style"]
	end

	ibu = untappd["IBU"]
	brewery = untappd["brewery"]
	if !brewery && homebrew
		brewery = homebrew["brewery"]
	end

	uRating = nil
	if untappd["score"]
		uRating = untappd["score"] * 2
	end
	
	if countryMapping[country]
		country = countryMapping[country]
	end	

	if extra["untappd"]["count"]
		stat["t"] = extra["untappd"]["count"]
	end

	if country
		stat["c"] = country
		increment(countries,country)
		increment(breweries,brewery)
		if item["score"] != "null" && uRating
			scoreDiffs += uRating - item["score"].to_f
			untappdRatings[uRating.to_i] += 1
			scoreDiffCount += 1
		end
	end

	if ibu && ibu > 0
		stat["IBU"] = ibu
	end

	if style
		stat["style"] = style
	end

	if brewery
		stat["b"] = brewery
	end

	if uRating && uRating > 0
		stat["uts"] = uRating
	end

	stats << stat
end

puts "missing ratings " + withoutRatings.length.to_s
puts "missing pct " + missingPct.to_s
puts "missing extra " + missingExtra.length.to_s
puts "missing untappdId " + missingUntappdId.length.to_s
puts "avg rating diff = " + (scoreDiffs/scoreDiffCount).to_s
puts JSON.pretty_generate(countries)
puts ratings
puts untappdRatings



date1 = Date.parse(stats[0]["d"])
date2 = Date.parse(stats[stats.length - 1]["d"])
months = (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month)
years = months/12;
months = months - years * 12;

timeText = years.to_s + " years";
if(months > 0) 
	timeText += " and " + months.to_s + " months";
end

quickStats = Hash.new
quickStats["total"] = stats.length
quickStats["breweries"] = breweries.length
quickStats["countries"] = countries.length
quickStats["months"] = months
quickStats["timeText"] = timeText

File.open("js/stats.json","w") do |f|
  f.write(JSON.pretty_generate(stats))
end

File.open("_data/quickStats.json","w") do |f|
  f.write(JSON.pretty_generate(quickStats))
end