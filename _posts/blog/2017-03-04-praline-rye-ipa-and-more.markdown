---
layout: default
slim-header: true
title:  "Praline, rye IPA and more"
date:   2017-03-04
category: blog
comments: true
thumbnail: boatrocker-pale.jpg
permalink: /blog/:year/:month/:day/:title.html
---

Another dreary morning in Sydney is a great opportunity to update the big album of beers with my latest 14 beers. I've found out that <a href="/brewery/sauce-brewing-co.html">Sauce Brewing Co</a> is going to be opening a new place in Marrickville which will just boost the suburb as a Mecca for beer.

There's been some real winners in here. The La Sirène Praline had so much hazelnut it was like a Nutella beer. My latest Skorubrew has a beautiful balanced smokiness that made it my best homebrew ever. 

There's been some bad ones too. The Buxton Pic tor was just awful. The Newstead two to the valley was pretty bad as well but they reached out to me about it which I respect so hopefully it was just a one off.

This afternoon I'm off to do a beer tasting course. Despite my extensive experience in drinking beer I really don't know that much about how to pick out tastes. Probably caused by my moderate indifference to food. Following that I'll probably stock up on my next crop of beers.

New beers
-----

<div class="beerlist row">
	{% assign rev = site.data.full %}
	{% for beer in rev %}
		{% if beer.date == "2017-03-03" %}
			{% include beerCell.html beer=beer %}
		{% endif %}
	{% endfor %}
</div>