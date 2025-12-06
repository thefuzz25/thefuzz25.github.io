# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Jekyll 4.3.x works correctly on Ruby 3.1 (not on Ruby 3.2)
gem "jekyll", "~> 4.3"

# Markdown processor required for GitHub-compatible Markdown
gem "kramdown-parser-gfm"

# Your custom plugin – works on Actions, not GitHub Pages
gem "jekyll-last-modified-at", git: "https://github.com/maximevaillancourt/jekyll-last-modified-at", branch: "add-support-for-files-in-git-submodules"

gem "jekyll-wikilinks"
gem "webrick", "~> 1.9"
gem "nokogiri"
