---
layout: page
title: Home
id: home
permalink: /
---
## Welcome! 🌱

<p style="padding: 3em 1em; background: #f5f7ff; border-radius: 4px;">
  Take a look at <span style="font-weight: bold">[[Your first note]]</span> to get started on your exploration.
</p>
#### Latest
{% assign recent_notes = site.notes | sort: "date" | reverse %}
  {% for note in recent_notes limit: 1%}
      <h4>
      <a class="internal-link" href="{{ site.baseurl }}{{ note.url }}">{{ note.title }}</a>
      </h4>
{{ note.date | date: "%B %d, %Y" }}
      <div class="entry">
        {{ post.content | strip_html | truncatewords: 12 }}
      </div>
  {% endfor %}

####  Recent

<ul>
  {% assign recent_notes = site.notes | sort: "date" | reverse %}
  {% for note in recent_notes limit: 20 %}
    <li>
      {{ note.date | date: "%Y-%m-%d" }} — 
      <a class="internal-link" href="{{ site.baseurl }}{{ note.url }}">{{ note.title }}</a>
    </li>
  {% endfor %}
</ul>

---