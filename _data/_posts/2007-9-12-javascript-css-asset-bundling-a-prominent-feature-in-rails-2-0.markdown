--- 
layout: post
title: Javascript/CSS asset bundling a prominent feature in Rails 2.0
---
<p>Actually this stuff even is in <a href="http://dev.rubyonrails.org/svn/rails/trunk/actionpack/lib/action_view/helpers/asset_tag_helper.rb">Rails Edge</a> ever since <a href="http://dev.rubyonrails.org/changeset/6164/trunk/actionpack/lib/action_view/helpers/asset_tag_helper.rb" title="Changeset 6164 for trunk/actionpack/lib/action_view/helpers/asset_tag_helper.rb - Rails Trac - Trac">February</a>! So in Rails Edge we already can do this:</p>

<pre><code>
&lt;%= javascript_include_tag :all, :cache => true %>
&lt;%= stylesheet_link_tag :all, :cache => true %>	
</code></pre>

<p>Or more flexibly:</p>

<pre><code>
&lt;%= stylesheet_link_tag "shop", "cart", "checkout", :cache => "payment"	%>
</code></pre>

<p>That's cool :)</p>

<p>And it's pretty much the same what my own <a href="http://www.artweb-design.de/projects/ruby-on-rails-plugin-bundled-css-and-javascript-assets">Bundled Assets</a> plugin does ... besides: my plugin also "compacts" Javascript and CSS by stripping things like comments and whitespace - and it still <strong>works on Rails 1.2</strong> of course.</p>

<p>Huh. Wow! </p>
