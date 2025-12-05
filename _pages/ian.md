---
layout: page
title: In a Nutshell
permalink: /ian
---
## In a Nutshell

My (wise) reflections on what was and my takes on what's to come. Spoiler: humour refuses to stay out of it.

#### Latest

{% include latest-card.html from="" %}
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