---
layout: page
title: Home
id: home
permalink: /
---
#### Latest
{% assign recent_notes = site.notes | sort: "date" | reverse %}
{% assign note = recent_notes.first %}
<h3>
  <a class="internal-link" href="{{ site.baseurl }}{{ note.url }}">
    {{ note.title }}
  </a>
</h3>

<p class="note-date">
  {{ note.date | date: "%B %d, %Y" }}
</p>

<div class="entry">
  {{ note.content | strip_html | truncatewords: 25 }}
</div>

<p style="padding: 3em 1em; background: #f5f7ff; border-radius: 4px;">
  Cannot figure out <span style="font-weight: bold">what to do</span> with this box. But it does look good.
</p>
{% assign recent_notes = site.notes | sort: "date" | reverse %}
{% assign note = recent_notes.first %}

<a href="{{ site.baseurl }}{{ note.url }}" class="card-link">
  <h3>{{ note.title }}</h3>
  <p class="note-date">
    {{ note.date | date: "%B %d, %Y" }}
  </p>
  <div class="entry">
    {{ note.content | strip_html | truncatewords: 25 }}
  </div>
</a>

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