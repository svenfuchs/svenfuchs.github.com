--- 
layout: post
title: Mephisto article list pagination plugin
---
<p class="update"><strong>Update:</strong> The following information is most probably outdated. Please refer to the <a href="/projects/mephisto-plugin-paged-article-lists" title="Mephisto Plugin: Paged Article Lists">Mephisto Plugin: Paged Article Lists</a> project page.</p>

<p>Searching for advice on how to do this <em>the right way</em> in Ruby on Rails I've found a lot of interesting stuff ... I just haven't found anything about <strong>how to overwrite an existing applications controller action</strong> - something that I considered necessary for that pagination functionality I wanted to realize. If you happen to be able to tell me something about this, please do.</p>

<p>So here's what I've been able to come up with myself.</p> 

<p style="text-decoration:line-through">I hook into the ActionController's before_filter and overwrite the entire method from there! Uuuuuuuha. Yes, I consider this aproach to be rather brutally hackish and ugly. It actually disturbs me if I look at this! I just don't know how to do it in a more apropriate way. Is there any?</p>
<p>([Update] I've found a less hackish way to overwrite the Controller in the meantime. I'll put some notes together about some useful plugin dev techniques that I've collected.)</p>

<p>Here's the code:</p>

<pre><a href="http://svn.artweb-design.de/stuff/mephisto/mephisto_paged_article_list">http://svn.artweb-design.de/stuff/mephisto/mephisto_paged_article_list</a></pre>

<p>[Update] I've added some notes on <a href="/2007/4/2/howto-use-mephisto-article-list-pagination-plugin">how to use this plugin</a>.</p>
