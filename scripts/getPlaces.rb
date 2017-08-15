require 'json'
require 'net/http'
require 'httpclient'

placeFilename = ARGV[0]
apiKey = ARGV[1]

if placeFilename == nil || apiKey == nil
	puts "Usage: ruby getPlaces.rb filename apiKey"
	exit
end


data = JSON.parse(File.read(placeFilename))
puts data