---
layout: post
title: Jekyll internals
category: []
---

Jekyll seems to work like magic. What I didn't quite expect was that it periodically regenerates, meaning that I don't have to rerun `bundle exec jekyll serve` to view an update. This makes me very curious about how Jekyll actually works, and the natural step would be look at its source code, which is written in Ruby. So I went to its github page and cloned its repo with

{% highlight bash %}
git clone git@github.com:jekyll/jekyll.git
{% endhighlight %}

which took two attempts, as I needed to first add an SSH key. Now that that's done I can go happy hacking after installing a Ruby IDE to navigate the codebase in a language I'm completely unfamiliar with.
