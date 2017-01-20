var beerData = [];

var countryCounts;
var styleCounts;
var breweryCounts;

var showCountryRatings = false;
var showStyleRatings = false;
var showBreweryRatings = false;
var showFullStyle = false;
var showFullBreweries = false;

var scatterPlotConfig = {};
scatterPlotConfig.xAxisName = getAxisName("abv");
scatterPlotConfig.xAxisValue = getAxisFunc("abv");

scatterPlotConfig.yAxisName = getAxisName("rating");
scatterPlotConfig.yAxisValue = getAxisFunc("rating");

function findTopBeer(withField,equalTo) {
  var filtered = beerData.filter(function(d) {
    return d[withField] == equalTo && d.score != undefined;
  });
  if(filtered.length == 0) {
    return null;
  }
  filtered = filtered.sort(function(a,b) {
    return b.score - a.score;
  });
  return filtered[0];
}

function getAxisName(type) {
  if(type == "rating") {
    return "My Rating";
  } else if (type == "abv") {
    return "ABV%";
  } else if (type == "uts") {
    return "Untappd Rating";
  } else if (type == "ibu") {
    return "IBU";
  } else if (type == "review") {
    return "Review Length";
  } else if (type == "date") {
    return "Date";
  }
}

function getAxisFunc(type) {
  if(type == "rating") {
    return function(d) { return d.score;};
  } else if (type == "abv") {
    return function(d) { return d.pct;};
  } else if (type == "uts") {
    return function(d) { return d.uts;};
  } else if (type == "ibu") {
    return function(d) { return d.IBU;};
  } else if (type == "review") {
    return function(d) { return d.r;};
  } else if (type == "date") {
    return function(d) { return new Date(d.d);};
  }
}

function convertHexToRgb(hex) {
  var match = hex.replace(/#/,'').match(/.{1,2}/g);
  var r = parseInt(match[0], 16);
  var g = parseInt(match[1], 16);
  var b = parseInt(match[2], 16);
  return [r,g,b];
}

function findColorBetween(left, right, fraction) {
  var leftRGB = convertHexToRgb(left);
  var rightRGB = convertHexToRgb(right);
  var newColor = [0,0,0];
  for (var i = 0; i < 3; i++) {
    newColor[i] = Math.round(leftRGB[i] + (rightRGB[i] - leftRGB[i]) * fraction);
  }
  return newColor;
}

function avgScore(c) {
  if(c.withScore > 0) {
    return c.totalScore / c.withScore;
  }
  return 0;
}

function showBasicTooltip(c,name,top,left) {
  var text = "";
  if(c) {
    text = c.count + " beer";
    if(avgScore(c)) {
      text += " avg rating " + avgScore(c).toFixed(2);
    }
  }
  showTooltip(name,text,top,left);
}

function showTooltip(title,text,top,left) {
  $("#tooltip-container .tooltip_key").text(title);
  $("#tooltip-container .tooltip_value").text(text);
  $("#tooltip-container .tooltip_beer").hide();
  $("#tooltip-container").show();

  d3.select("#tooltip-container")
    .style("top", top + "px")
    .style("left", left + "px");
}

function showTopBeer(beer) {
  if(!beer) {
    return;
  }
  var text = "Top beer: " + beer.name + " " +  beer.score + "/10"
  $("#tooltip-container .tooltip_beer").text(text);
  $("#tooltip-container .tooltip_beer").show();
}

function addSVG(element,width,height) {
  var div = d3.select(element)
  if(width == undefined) {
    width = parseInt(div.style("width"))
  }

  return div.append("svg").attr("width", width).attr("height", height);
}

function addSingleSVG(element,aspect) {
  $(element).empty();
  var div = d3.select(element)
  var width = parseInt(div.style("width"))
  var height = width * aspect;
  return div.append("svg").attr("width", width).attr("height", height);
}

function makeCountryChart(countryCounts,showAVG) {
  var valFunc = function(d) {
    return showAVG ? avgScore(d) : d.count;
  }

  var maxCount = d3.max(d3.values(countryCounts),valFunc);
  var minCount = d3.min(d3.values(countryCounts),valFunc);


  var svg = addSingleSVG("#map",0.8);
  var width = parseInt(svg.attr("width"));
  var height = parseInt(svg.attr("height"));
  
  var projection = d3.geoMercator()
      .scale((width + 1) / 2 / Math.PI)
      .translate([width / 2, height / 2])
      .precision(.1);
  
  var path = d3.geoPath()
      .projection(projection);
  
  var graticule = d3.geoGraticule();
  
  svg.append("path")
      .datum(graticule)
      .attr("class", "graticule")
      .attr("d", path);

  

  d3.json("https://s3-us-west-2.amazonaws.com/vida-public/geo/world-topo-min.json", function(error, world) {
    var countries = topojson.feature(world, world.objects.countries).features;
  
    svg.append("path")
       .datum(graticule)
       .attr("class", "choropleth")
       .attr("d", path);
  
    var g = svg.append("g");
  
    var country = g.selectAll(".country").data(countries);
  
    country.enter().insert("path")
        .attr("class", "country")
        .attr("d", path)
        .attr("title", function(d) { return d.properties.name; })
        .style("fill", function(d) {
          if (countryCounts[d.properties.name]) {
            var val = valFunc(countryCounts[d.properties.name]);
            var c = (val - minCount) / (maxCount - minCount);
            var color = findColorBetween("#FFFBB1","#BE6C01",Math.sqrt(c));
            return "rgb(" + color[0] + "," + color[1] + "," + color[2] + ")";
          } else {
            return "#ccc";
          }
        })
        .on("mousemove", function(d) {
            var c = countryCounts[d.properties.name];
            
            var coordinates = d3.mouse(this);
            
            var map_width = $('.choropleth')[0].getBoundingClientRect().width;
            
            var top = (d3.event.layerY + 15);
            var left = 0;
            if (d3.event.pageX < map_width / 2) {
              left = (d3.event.layerX + 15);
            } else {
              var tooltip_width = $("#tooltip-container").width();
              left = (d3.event.layerX - tooltip_width - 30);
            }
            
            showBasicTooltip(c,d.properties.name,top,left);  
            var best = findTopBeer("c",d.properties.name);
            showTopBeer(best);
            $(this).attr("fill-opacity","0.7");

        })
        .on("mouseout", function() {
                $(this).attr("fill-opacity", "1.0");
                $("#tooltip-container").hide();
            });
    
    g.append("path")
        .datum(topojson.mesh(world, world.objects.countries, function(a, b) { return a !== b; }))
        .attr("class", "boundary")
        .attr("d", path);
    
    svg.attr("height", height * 2.2 / 3);
  });
  
  d3.select(self.frameElement).style("height", (height * 2.3 / 3) + "px");
}

function makeStyleChart(element,styleCounts,showRatings,full) {
  var field = element == "#style-svg" ? "style" : "b";
  var valFunc = function(d) {
    return showRatings ? avgScore(d) : d.count;
  }

  styleCounts = styleCounts.sort(function(a,b) {
    return valFunc(b) - valFunc(a);
  });

  if(!full) {
    styleCounts = styleCounts.slice(0,20);
  }

  var axisMargin = 20,
    margin = 40,
    valueMargin = 4,
    barHeight = 25,
    barPadding = 4,
    labelWidth = 0;

  var height = styleCounts.length * (barHeight + barPadding);

  var max = d3.max(styleCounts, valFunc);

  $(element).empty();
  var svg = addSVG(element,undefined,height);
  var width = parseInt(svg.attr("width"));

  var bar = svg.selectAll("g").data(styleCounts)
    .enter()
    .append("g");

  bar.attr("class", "bar")
    .attr("cx",0)
    .attr("transform", function(d, i) {
      return "translate(" + margin + "," + (i * (barHeight + barPadding) + barPadding) + ")";
    });

  bar.append("text")
    .attr("class", "label")
    .attr("y", barHeight / 2)
    .attr("dy", ".35em") //vertical align middle
    .text(function(d){
      return d.name;
    }).each(function() {
      labelWidth = Math.ceil(Math.max(labelWidth, this.getBBox().width));
    });

  var scale = d3.scaleLinear()
    .domain([0, max])
    .range([0, width - margin*2 - labelWidth]);


  bar.append("rect")
    .attr("transform", "translate("+labelWidth+", 0)")
    .attr("height", barHeight)
    .attr("width", function(d){
      return scale(valFunc(d));
    });

  bar.append("text")
    .attr("class", "value")
    .attr("y", barHeight / 2)
    .attr("dx", -valueMargin + labelWidth) //margin right
    .attr("dy", ".35em") //vertical align middle
    .attr("text-anchor", "end")
    .text(function(d){
      return showRatings ? avgScore(d).toFixed(2) : d.count;
    })
    .attr("x", function(d){
      var width = this.getBBox().width;
      return Math.max(width + valueMargin, scale(valFunc(d)));
    });

  bar.on("mousemove", function(d){
    var top = d3.event.pageY-25;
    var left = d3.event.pageX+10;
    showBasicTooltip(d,d.name,top,left);
    var best = findTopBeer(field,d.name);
    showTopBeer(best);
  });
  
  bar.on("mouseout", function(d){
    $("#tooltip-container").hide();
  });
}

function makeScoreChart(scores) {

  var fullWidth = 960,
    fullHeight = 400,
    margin = {top: 10, right: 30, bottom: 30, left: 30},
    width = fullWidth - margin.left - margin.right,
    height = fullHeight - margin.top - margin.bottom;

  var svg = addSVG("#canvas-svg",fullWidth,fullHeight);
  var g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var keys = ["scores","uts"];
  var keyNames = {scores:"My ratings",uts:"Untappd ratings"};

  var x0 = d3.scaleBand().rangeRound([0, width]).paddingInner(0.1);

  var x1 = d3.scaleBand().padding(0.05);
  var y = d3.scaleLinear().rangeRound([height, 0]);
  var z = d3.scaleOrdinal().range(["#98abc5", "#8a89a6"]);

  x0.domain(scores.map(function(d) { return d.value; }));
  x1.domain(keys).rangeRound([0, x0.bandwidth()]);
  y.domain([0, d3.max(scores, function(d) { return d3.max(keys, function(key) { return d[key]; }); })]).nice();

  g.append("g")
    .selectAll("g")
    .data(scores)
    .enter().append("g")
      .attr("transform", function(d) { return "translate(" + x0(d.value) + ",0)"; })
    .selectAll("rect")
    .data(function(d) { return keys.map(function(key) { return {key: key, value: d[key]}; }); })
    .enter().append("rect")
      .attr("x", function(d) { return x1(d.key); })
      .attr("y", function(d) { return y(d.value); })
      .attr("width", x1.bandwidth())
      .attr("height", function(d) { return height - y(d.value); })
      .attr("fill", function(d) { return z(d.key); });

  g.append("g")
      .attr("class", "axis")
      .attr("transform", "translate(0," + height + ")")
      .call(d3.axisBottom(x0));

  g.append("g")
      .attr("class", "axis")
      .call(d3.axisLeft(y).ticks(null, "s"))
    .append("text")
      .attr("x", 2)
      .attr("y", y(y.ticks().pop()) + 0.5)
      .attr("dy", "0.32em")
      .attr("fill", "#000")
      .attr("font-weight", "bold")
      .attr("text-anchor", "start")
      .text("Rating count");


  var legend = g.append("g")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "end")
    .selectAll("g")
    .data(keys.slice().reverse())
    .enter().append("g")
      .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

  legend.append("rect")
      .attr("x", width - 19)
      .attr("width", 19)
      .attr("height", 19)
      .attr("fill", z);

  legend.append("text")
      .attr("x", width - 24)
      .attr("y", 9.5)
      .attr("dy", "0.32em")
      .text(function(d) { return keyNames[d]; });

}

function makeScatterplot(beers,config) {
  beers = beers.filter(function(i) {
    return config.xAxisValue(i) != undefined && config.yAxisValue(i) != undefined;
  });

  var fullWidth = 960,
    fullHeight = 800,
    margin = {top: 10, right: 30, bottom: 30, left: 30},
    width = fullWidth - margin.left - margin.right,
    height = fullHeight - margin.top - margin.bottom;

  var x = d3.scaleLinear().range([0, width]);
  var y = d3.scaleLinear().range([height, 0]);

  var xAxis = d3.axisBottom(x);
  var yAxis = d3.axisLeft(y);
  $("#scatterplot-svg").empty();
  var svg = addSVG("#scatterplot-svg",fullWidth,fullHeight)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  x.domain(d3.extent(beers, config.xAxisValue)).nice();
  y.domain(d3.extent(beers, config.yAxisValue)).nice();

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
    .append("text")
      .attr("class", "label")
      .attr("x", width)
      .attr("y", -6)
      .style("text-anchor", "end")
      .text(config.xAxisName);

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("class", "label")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text(config.yAxisName)

  var dot = svg.selectAll(".dot")
      .data(beers)
    .enter().append("circle")
      .attr("class", "dot")
      .attr("r", 3.5)
      .attr("cx", function(d) { return x(config.xAxisValue(d)); })
      .attr("cy", function(d) { return y(config.yAxisValue(d)); })

    console.log(dot);

    dot.on("mousemove", function(d){
      var top = d3.event.pageY-25;
      var left = d3.event.pageX+10;
      var text = d.pct + "%";
      showTooltip(d.name,text,top,left);
    });
  
  dot.on("mouseout", function(d){
    $("#tooltip-container").hide();
  });

}

function increment(hash,key) {
  if(hash[key] == undefined) {
    hash[key] = 0;
  }
  hash[key] = hash[key] + 1;
}

function incrementCountAndScore(hash,key,score) {
  if(hash[key] == undefined) {
    hash[key] = {count:0,withScore:0,totalScore:0};
  }
  hash[key].count = hash[key].count + 1;
  if(score != undefined) {
    hash[key].withScore = hash[key].withScore + 1;
    hash[key].totalScore = hash[key].totalScore + score;
  }
}

function extractCountries(data) {
  countries = {};
  data.forEach(function(i) {
    incrementCountAndScore(countries,i.c,i.score)
  });
  return countries
}

function extractField(data,fieldName) {
  var results = {};
  data.forEach(function(i) {
    if(i[fieldName] != undefined) {
      incrementCountAndScore(results,i[fieldName],i.score);
    }
  });

  var keys = Object.keys(results);

  return keys.map(function(s) {
    var v = results[s];
    v["name"] = s;
    return v;
  })
}



function extractScoreFrequency(data) {
  var scores = {};
  var untappedScores = {};
  data.forEach(function(i) {
    if(i.score && i.uts) {
      increment(scores,i.score.toFixed(0));
      increment(untappedScores,i.uts.toFixed(0));
    }
  });
  var all = [];

  for(i = 0; i <= 10; i+=1) {
    var key = i.toFixed(0);
    var item = {value:key, scores:scores[key] || 0,uts:untappedScores[key] || 0};
    all.push(item);
  }

  return all;
}

function extractScores(data) {
  return data.filter(function(i) {
    return i.score != undefined && i.uts != undefined;
  });
}

function monthDiff(d1, d2) {
    var months;
    months = (d2.getFullYear() - d1.getFullYear()) * 12;
    months -= d1.getMonth() + 1;
    months += d2.getMonth();
    return months <= 0 ? 0 : months;
}

d3.select(window).on('resize', function() {
  if(beerData) {
    redrawCharts(beerData); 
  }
});

$("#scatter-form input").change(function() {
  var v = this.value;
  if(this.name == "x") {
    scatterPlotConfig.xAxisName = getAxisName(v);
    scatterPlotConfig.xAxisValue = getAxisFunc(v);
  } else {
    scatterPlotConfig.yAxisName = getAxisName(v);
    scatterPlotConfig.yAxisValue = getAxisFunc(v);
  }
  makeScatterplot(beerData,scatterPlotConfig);
});

$("#map-form input").change(function() {
  showCountryRatings = this.value == "rating";
  makeCountryChart(countryCounts,showCountryRatings);
});

$("#style-form input").change(function() {
  if(this.name == "metric") {
    showStyleRatings = this.value == "rating";
  } else {
    showFullStyle = this.value == "all";
  }
  makeStyleChart("#style-svg",styleCounts,showStyleRatings,showFullStyle);
});

$("#brewery-form input").change(function() {
  if(this.name == "metric") {
    showBreweryRatings = this.value == "rating";
  } else {
    showFullBreweries = this.value == "all";
  }
  makeStyleChart("#brewery-svg",breweryCounts,showBreweryRatings,showFullBreweries);
});

function redrawCharts(data) {
  makeCountryChart(countryCounts,showCountryRatings);
}

d3.json("/js/stats.json", function(err, data) {
  beerData = data;
  countryCounts = extractCountries(data);
  styleCounts = extractField(data,"style");
  breweryCounts = extractField(data,"b");
  var scoreFrequency = extractScoreFrequency(data);

  var firstDate = new Date(data[0].d);
  var lastDate = new Date(data[data.length-1].d);
  var months = monthDiff(firstDate,lastDate);
  var years = Math.floor(months/12);
  months = months - years * 12;

  makeCountryChart(countryCounts,showCountryRatings);
  makeStyleChart("#style-svg",styleCounts,showStyleRatings,showFullStyle);
  makeStyleChart("#brewery-svg",breweryCounts,showCountryRatings,showFullBreweries);
  //makeScoreChart(scoreFrequency);
  makeScatterplot(data,scatterPlotConfig);

  $("#beer-count").text(data.length);
  $("#country-count").text(Object.keys(countryCounts).length);
  $("#brewery-count").text(Object.keys(breweryCounts).length);
  var timeText = years + " years";
  if(months > 0) {
    timeText += " and " + months + " months";
  }
  $("#time-period").text(timeText);


});

