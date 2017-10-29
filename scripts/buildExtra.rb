require 'rubygems'
require 'json'
require 'net/http'
require 'httpclient'
require 'launchy'
require 'slugify'

ACCESS_TOKEN = ARGV[0]
SECRET = ARGV[1]

if ACCESS_TOKEN == nil || SECRET == nil
	puts "Usage: ruby buildExtra.rb UNTAPPED_ID UNTAPPED_SECRET"
	exit
end

file = File.read('js/raw.json')
allBeers = JSON.parse(file)
existing = JSON.parse(File.read('js/extra.json'))

extraData = Hash.new

allBeers.each do |item|
	d = Hash.new
	d["untappd"] = Hash.new
	d["untappd"]["id"] = ""
	old = existing[item["name"]]
	if old == nil
		old = existing[item["name"].gsub("'", "\\\\'")]
	end
	
	if old != nil
		d["untappd"] = old["untappd"]
		if(old["homebrew"])
			d["homebrew"] = old["homebrew"]
		end
	end

	extraData[item["name"]] = d
end

count = 0

extraData.each do |item|
	hash = item[1]["untappd"]


	if hash["id"].length > 0 && (hash["style"] == nil || hash["count"] == nil)
		url = "https://api.untappd.com/v4/beer/info/" + hash["id"] + "?client_id=" + ACCESS_TOKEN + "&client_secret=" + SECRET
		clnt = HTTPClient.new;
		data = clnt.get_content(url)
		result = JSON.parse(data)
		beer = result["response"]["beer"]
		brewery = beer["brewery"]
		hash["style"] = beer["beer_style"]
		hash["IBU"] = beer["beer_ibu"]
		hash["score"] = beer["rating_score"]
		hash["brewery"] = brewery["brewery_name"]
		hash["breweryId"] = brewery["brewery_id"]
		hash["country"] = brewery["country_name"]
		hash["name"] = beer["beer_name"]
		hash["abv"] = beer["beer_abv"]
		hash["count"] = beer["stats"]["total_count"]
		hash["users"] = beer["stats"]["total_user_count"]
		puts "fetch beer " + hash["name"]

		File.open("untappd/beer/" + hash["id"] + ".json","w") do |f|
			f.write(JSON.pretty_generate(result))
		end
		count = count + 1
		if count > 50
			break
		end
	end

	if hash["id"].length > 0
		hash["url"] = "https://untappd.com/b/" + hash["brewery"].slugify + "-" + hash["name"].slugify + "/" + hash["id"]
	end
end

missing = extraData.select {|key,value| value["untappd"]["id"].length == 0 && value["homebrew"] == nil}
puts missing.keys.map { |e|  
	"https://untappd.com/search?q=" + e
}




File.open("js/extra.json","w") do |f|
  f.write(JSON.pretty_generate(extraData))
end

