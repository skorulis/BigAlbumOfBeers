require 'json'
require 'slugify'

file = File.read('_data/raw.json')
allBeers = JSON.parse(file)

allBeers.each do |item|
	date = "2016-11-09-"
	filename = "_posts/" + date + item["name"].slugify + ".md"
	File.open(filename,'w') { |file|
		file.puts('---')
		file.puts('layout: beer')
		file.puts('title: ' + item["name"])
		file.puts('score: ' + item["score"])
		file.puts('img: ' + item["img"])
		file.puts('desc: ' + item["desc"])
		file.puts('permalink: /beer/:title.html')
		file.puts('---')
	}

end