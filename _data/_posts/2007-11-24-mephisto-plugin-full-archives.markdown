--- 
layout: post
title: "Mephisto Plugin: Full archives (tricky edition)"
---
<p>This is a pretty simple plugin that adds a full archives view to Mephisto's own archives.</p>

<p>By "full archive" simply a list of all your blog posts is meant, most probably just titles grouped by month. This is something that's supported by quite some big blogging engines, but not Mephisto.</p>

<p>To install the plugin just use the script/plugin installer. E.g.:</p>

<pre><code>
script/plugin install \
  <a href="http://svn.artweb-design.de/stuff/mephisto/mephisto_full_archives">http://svn.artweb-design.de/stuff/mephisto/mephisto_full_archives</a>
</code></pre>

<p>You will also have to change your archives.liquid template to display the view accoringly. I've provided an example tempate that you can just copy and paste to your theme. Look at:</p>

<pre><code>
<a href="http://svn.artweb-design.de/stuff/mephisto/mephisto_full_archives/lib/templates/archive.liquid.example">mephisto_full_archives/lib/templates/archive.liquid.example</a>	
</code></pre>

<p>You can see the plugin in action here:</p>
	
<ul>
	<li><a href="http://www.artweb-design.de/archives">here on my own blog</a> </li>
	<li><a href="http://latherrinserepeat.org/articles" title="Lather Rinse Repeat">here on Liz's homepage</a></li>
</ul>
	
<p>Now guess why this plugin is tagged "tricky edition" ;-)</p>
