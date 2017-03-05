---
layout: default
slim-header: true
title:  "Beer Cartel Beer Tasting"
date:   2017-03-05
category: blog
comments: true
thumbnail: tasting.jpg
permalink: /blog/:year/:month/:day/:title.html
---

Yesterday I headed to [Beer Cartel](http://www.beercartel.com.au/) for an introduction into craft beer. Not that I'm new to craft beer but it's nice to hear from someone who really knows what they're talking about. The event consisted of tasting 5 beers in small quantities showcasing a few different styles. This of course doesn't count as a proper tasting to me so I'll have to try these beers again to give a proper rating.

{% include blogImage.html url="/img/blog/other/beer-cartel-tasting.jpg" desc="Tasting room at Beer Cartel" %}

After the tasting I purchased a good stock of beers to add to my album. The range was pretty good but I don't think I really managed to find the juicy IPA that I'm always searching for. Managed to get through a few of them having a few beers with friends but really didn't find any amazing beers. The rest of the box may still contain some hidden treasures.

{% include blogImage.html url="/img/blog/other/boxes-of-beer.jpg" desc="Going to a beer shop almost always ends like this" %}

Once again I've managed to skip the hangover despite copious drinking. Not sure exactly how this is happening but I'm not complaining.

New beers
-----

<div class="beerlist row">
	{% assign rev = site.data.full %}
	{% for beer in rev %}
		{% if beer.date == "2017-03-05" %}
			{% include beerCell.html beer=beer %}
		{% endif %}
	{% endfor %}
</div>