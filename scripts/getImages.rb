require 'slugify'
require 'json'
require 'net/http'
require 'httpclient'

raw = JSON.parse(File.read('_data/full.json'))

allData = Hash[]

raw.each do |item|
    id = item["name"].slugify
    allData[id] = Hash[]
    allData[id]["img"] = item["img"]
    target = "img/list/" + id + ".jpeg"
    if(!File.exists?(target))
        clnt = HTTPClient.new;
	    data = clnt.get_content(item["img"])
        file = File.new(target,"wb");
        file.write(data)
        puts target
    end
    item["imgPath"] = target
end

rawFile2 = File.new("_data/full.json","wb")
rawFile2.write(JSON.pretty_generate(raw))
