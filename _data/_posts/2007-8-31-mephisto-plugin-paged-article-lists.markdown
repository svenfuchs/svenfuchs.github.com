--- 
layout: post
title: "Mephisto Plugin: Paged Article Lists"
---
<div class="update"><p><strong>Please note:</strong> These instructions work with the following setups. They are not tested with other combinations and might break on older versions of Mephisto or Rails. Please drop me an email if you've successfully run this plugin on other setups.</p>
<ul>
<li>Mephisto Edge rev 3066 on Rails 2.0</li>
</ul>
</div>
<h3>Installation</h3>

<p>Just use the script/plugin installer. E.g.:</p>

<pre><code>script/plugin install \
  http://svn.artweb-design.de/stuff/mephisto/mephisto_paged_article_list</code></pre>

<p>Also, as the plugin relies on will_paginate you'll need the will_paginate_liquidized plugin, which you can install like this:</p>

<pre><code>script/plugin install \
  http://svn.artweb-design.de/stuff/rails/will_paginate_liquidized</code></pre>

<p>After installing the plugin, you'll have to tweak your templates manually. You can use the following filters:</p>

<h3>Prev/next page links</h3>

<p>The plugin provides you with a convenient Liquid filter that will output "previous/next articles" links out of the box. Just add this to your templates:</p>

<pre><code>{{ articles | prev_next_page_links: path_info }}</code></pre>

<p>This will result in something like:</p>

<p><img src="/assets/2007/9/26/pagination_prev_next.png" /></p>

<p>You can also provide two alternative link texts and/or a separator to this filter like this:</p>

<pre><code>{{ articles | prev_next_page_links: path_info, 'previous', 'next' }}
{{ articles | prev_next_page_links: path_info, 'previous', 'next', '&amp;middot;' }}
{{ articles | prev_next_page_links: path_info, '&amp;middot;' }}</code></pre> 

<h3>Single link filters</h3>

<p>You might want to control these links individually though. You can then (like before) use the following filters:</p>

<pre><code>{{ articles | link_to_prev_page: path_info }}   
{{ articles | link_to_next_page: path_info }}</code></pre>

<p>Again, you can inject a different link text. Like so:</p>

<pre><code>{{ articles | link_to_prev_page: path_info, 'previous' }}   
{{ articles | link_to_next_page: path_info, 'next' }}</code></pre>

<h3>Digg-style navigation</h3>

<p>As we are riding on the back of will_paginate, only some minor additions were necessary to enable the usage of the will_paginate view helper from within our Liquid templates. That means that now you can do this:</p>

<pre><code>{{  articles | will_paginate: path_info }}</code></pre>

<p>... which will result in a nice list of pagination links. You can now easily add some CSS styles (e.g., like proposed here) and achieve something that looks very similar to the paginators on Digg, Flickr and others. Like this:</p>

<p><img src="/assets/2007/9/26/pagination_digg.png" /></p>

<p>(To get the boxy style you can easily some CSS like the <a href="http://www.strangerstudios.com/sandbox/pagination/diggstyle_css.txt">stylesheet</a> proposed <a href="http://www.strangerstudios.com/sandbox/pagination/diggstyle.php" title="Digg-style Pagination">here</a>).</p>

<h3>Further reading</h3>

<p>You can read more about this plugin here:</p>
<ul>
<li><a href="/2007/3/28/mephisto-article-list-pagination-plugin" title="Mephisto article list pagination plugin - artweb design">Initial announcement (outdated)</a></li>
<li><a href="/2007/4/2/howto-use-mephisto-article-list-pagination-plugin" title="Howto use: Mephisto article list pagination plugin - artweb design">Howto for first version (Rails 1.2.3)</a></li>
<li><a href="/2007/10/11/mephisto-pagination-plugin-updated-what-s-new" title="Mephisto Pagination Plugin updated: what's new? - artweb design">Announcment: Update to Rails Edge compatible version using will_paginate</a></li>
</ul>

<h3>Feedback?</h3>

<p>As always: very appreciated! Please drop me an e-mail or use the comments on my blog.</p>
