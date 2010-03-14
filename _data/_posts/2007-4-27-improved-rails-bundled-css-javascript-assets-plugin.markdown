--- 
layout: post
title: "Serve CSS and Javascript even faster: improved Rails bundled_assets plugin"
---
<h2>JS compression: up to 10 times faster!</h2>

<p>Witold pointed me to the fact that the Javascript compression through JSMin might take a significant amount of time. On my own machine that's:</p>

<pre><code>
$ time ruby vendor/plugins/bundled_assets/lib/jsmin.rb &lt;tmp/in.js > tmp/out.js 
real    0m2.851s
user    0m2.813s
sys     0m0.017s
</code></pre>

<p>... with in.js being ~ 250kb large. 250kb of Javascript definitely aren't that unusual these days and Witold reported even worse execution times.</p>

<p>This may or may not be a problem for your app in <strong>production mode</strong>. In most cases it won't be a problem, I guess, because Rails' page caching mechanism makes sure that this lag will only occur once immediately after you've published changes to your Javascript <strong>and</strong> cleared your public/bundles cache directory. On the other hand on high-performance sites every bit of performance may count and you probably don't want to wonder a lot about this bit.</p>

<p>Furthermore, depending on how large your Javascript files are and how snappy you expect your application to be in <strong>development mode</strong> you might definitely want to do something about this: Rails' page caching mechanism won't cache <em>anything</em> when in development mode (which of course is the right thing to do) ... and that means for our bundles that they will be re-created with every single request. So that lag occurs with every page request that includes our Javascript bundle, too.</p>

<p>Now, there are two general approaches here to speed things up a bit, of course:</p>

<ul>
	<li>completely turn of Javascript compression</li>
	<li>use a faster implementation of the compressor</li>
</ul>

<p>Turning stuff off through a configuration option is done easily, but how about a faster implementation? Good news is that there's a <a href="http://www.crockford.com/javascript/jsmin.c">C version of JSMin</a>. It will compress the same Javascript libraries from the benchmark above in the blink of an eye:</p>

<pre><code>
$ time vendor/plugins/bundled_assets/lib/jsmin &lt;tmp/in.js > tmp/out.js 
real    0m0.030s
user    0m0.023s
sys     0m0.007s
</code></pre>

<p>So this should work well even in development mode. On the other hand you might reportedly have problems to get this thing compiled, deployed or running (usually it's very easy!) depending on your provider or type of webspace.</p>

<p>Thus, you can now choose between these both options and customize the plugin to your needs. See below for the configuration options.</p>


<h2>Keep CSS comments for your scary CSS hacks</h2>

<p>If you are using some scary CSS hacks that rely on CSS comments the regular expressions that are used for CSS compression will probably prove a bit too greedy for you:</p>

<pre><code>@content.gsub!(/\/\*(.*?)\*\/ /, "")</code></pre>

<p>So far you had to comment out that line of code. Now you can conveniently use a config option here, too. See below.</p>


<h2>New config options for your asset bundles</h2>

<p>You can specify any of the following config options e.g. at the end of your <code>environment.rb</code> or <code>environments/development.rb</code>.</p>

<p>To completely turn compression for CSS and Javascript on/off use this:</p>

<pre><code>AssetsBundle.options[:compress] = [:css, :js]</code></pre>

<p>(Valid values are: <code>false</code>, <code>[]</code>, <code>:css</code>, <code>:js</code>, <code>[:css]</code>, <code>[:js]</code>, <code>[:css, :js]</code>.)</p>

<p>Also, you can provide a path to a Javascript compressor that will be used by the plugin. E.g. instead of the default setting which points the Ruby interpreter to the Ruby implementation of JSMin you might want to use:</p>

<pre><code>
AssetsBundle.options[:jsmin] = %W(#{RAILS_ROOT}/vendor/plugins/bundled_assets/lib/jsmin)	
</code></pre>

<p>This way the plugin would use a compiled C version of JSMin placed in the lib directory. Of course you can specify whatever path might work for you.</p>

<p>To turn off stripping comments from CSS you can say:</p>

<pre><code>AssetsBundle.options[:css_keep_comments] = true</code></pre>

<p>I've also made the CSS and Javascript source paths configurable. You can specify them like this:</p>

<pre><code>
AssetsBundle.options[:paths][:css] = '/public/stylesheets/my_css'
AssetsBundle.options[:paths][:js] = '/public/stylesheets/my_js'
</code></pre>

<p>Like described in the <a href="/2007/4/13/rails-plugin-blazing-fast-page-loads-through-bundled-css-and-javascript">inital post about this article</a> you can also specify hole subdirectories to include all CSS/Javascript files that are found therein. So together with these config options this should prove flexible enough, I guess.</p>


<h2>A nasty typo in the Ruby JSMin implementation</h2>

<p>It's really only a typo but it's a potentially nasty one. You might have noticed it in the <a href="http://www.crockford.com/javascript/jsmin.rb">Ruby JSMin implementation</a> yourself if your Javascript code contains lines that aren't terminated by a semicolon (which of course is perfectly legal in Javascript). In this case you might have gotten Javascript syntax errors.  </p>

<p>I've patched the version of JSMin that comes with the Rails plugin, the patch has been added to the repository and Douglas Crockford has been notified.</p>


<h2>Where is it?</h2>

<p>Like before you can check this stuff out from here:</p>

<p><a href="http://svn.artweb-design.de/stuff/rails/bundled_assets">http://svn.artweb-design.de/stuff/rails/bundled_assets</a>.</p>


<h2>Feedback?</h2>

<p>What do you think? Suggestions? Improvements? Problems?</p>
