---
layout: default
slim-header: true
title:  "Feeling Good"
date:   2017-02-11
category: blog
comments: true
thumbnail: fox-hat.jpg
permalink: /blog/:year/:month/:day/:title.html
---

Most days after a visit to [Parsons](https://www.parsonsbar.com.au/) I'm significantly hungover and spend the day lounging around. Today I've managed to [brew a beer](http://homebrew.skorulis.com/brew/2017/02/01/skorubrew-20.html), hit the gym, clean a little, do some shopping and upload my latest beers including a couple I had today. Not bad for a day that I thought I would spend feeling like death in the sweltering 43 degrees of Sydney.

Here's my latest instalment to the big album of beers.

<div class="beerlist row">
	{% assign rev = site.data.full %}
	{% for beer in rev %}
		{% if beer.date == "2017-02-11" %}
			{% include beerCell.html beer=beer %}
		{% endif %}
	{% endfor %}
</div>



