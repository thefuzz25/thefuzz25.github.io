---
layout: page
title: Home
id: home
permalink: /
---
#### Latest
{% assign recent_notes = site.notes | sort: "date" | reverse %}
{% assign note = recent_notes.first %}

<div class="card-link">
  <a href="{{ site.baseurl }}{{ note.url }}">
    <h3>{{ note.title }}</h3>
    <p class="note-date">
      {{ note.date | date: "%B %d, %Y" }}
    </p>
    <div class="entry">
      {{ note.content | strip_html | truncatewords: 25 }}
    </div>
  </a>
</div>


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
---