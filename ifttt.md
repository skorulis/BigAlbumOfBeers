---
layout: basic
title: IFTTT setup instructions
---

What is IFTTT
=====

IFTTT stands for If This Then That. It's a website that helps to link various services together. To keep the extension simple it sends notifications through IFTTT and lets you choose how to handle them rather than trying to create multiple notifications that please everybody.

Getting Started
======

* The first thing you need to do is sign up to [IFTTT](https://ifttt.com). 
* Go to the [maker internal page](https://internal-api.ifttt.com/maker). Click connect if you haven't used this service before.
* There will be a field marked "Your key is". Take the value here and paste it into the "IFTTT maker key" field of the beermoney balances settings page. If you don't do this step correctly then you won't get any notifications. Make sure notifications are enabled.
* Once you've done this go to the page to create a [new applet](https://ifttt.com/create).
* Click on the + and select Maker from the list of services. 
* There should only be one trigger to choose from. Choose "Receive a web request"
* It will ask you for an event name, Enter:
```beermoney-no-points```
* Click on the next +. For the purposes of this guide select the email option. If you're an advanced user feel free to select the action of your choice.
* Chose the "Send me an email" action
* For the subject enter: {% raw %}```{{Value1}} has stopped earning beermoney``` {% endraw %}


* For the body enter: {% raw %}
```{{Value1}} has not recorded any balance change since {{Value2}}<br>
Sent: {{OccurredAt}}<br>
From Beermoney-balance extension```
{% endraw %}


* Press create action and you're done.
* Now you decide how often you want each app to check your balance and how long you want to wait before being notified. It might take some tweaking to find values that work for you.