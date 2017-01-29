require 'json'

file = File.read('js/raw.json')
allBeers = JSON.parse(file)

all = ""

allBeers.each do |item|
	all = all + item["desc"].downcase + "\n"
end

all = all.gsub("i've","")
all = all.gsub("doesn't","doesnt")
all = all.gsub("it's","its")

puts "word count " + all.scan(/[[:alpha:]]+/).count.to_s

File.open("_data/words.txt",'w') { |file|
	file.puts(all)
}