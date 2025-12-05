---
layout: page
title: Home
id: home
permalink: /
---
#### Latest

{% include latest-card.html %}
####  Recent
<ul class="no-bullets">
  {% assign recent_notes = site.notes | sort: "date" | reverse %}
  {% for note in recent_notes limit: 20 %}
	  <li>
      {{ note.date | date: "%Y · %m" }} &nbsp;&nbsp;
      <a class="internal-link" href="{{ site.baseurl }}{{ note.url }}">{{ note.title }}</a>
      </li>
  {% endfor %}
</ul>