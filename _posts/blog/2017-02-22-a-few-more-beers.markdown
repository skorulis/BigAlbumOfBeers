---
layout: default
slim-header: true
title:  "A few more beers"
date:   2017-02-22
category: blog
comments: true
thumbnail: triple-ipa.jpg
permalink: /blog/:year/:month/:day/:title.html
---

Thought I had a lot more beers to upload but it turns out it's only another 10. I think my drunken, social self missed out a few during more birthday event. The big one here is the Wolfmother triple IPA that I've been waiting a long time to drink. Not let down at all.

<div class="beerlist row">
	{% assign rev = site.data.raw %}
	{% for beer in rev %}
		{% if beer.date == "2017-02-22" %}
			{% include beerCell.html beer=beer %}
		{% endif %}
	{% endfor %}
</div>