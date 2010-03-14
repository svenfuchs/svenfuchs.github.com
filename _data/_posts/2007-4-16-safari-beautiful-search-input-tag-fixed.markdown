--- 
layout: post
title: Safari's beautiful search tag is broken - let's fix that
---
<h2>Everybody's proprietary darling</h2>

<p>Clearly I'm late <a href="http://andrewescobar.com/archive/2005/06/02/search-field-history/">to</a> <a href="http://www.bartelme.at/journal/archive/safaris_search_field/">the</a> <a href="http://www.37signals.com/svn/archives2/searchin_safari.php">party</a> with this, but hey! :-)</p>

<p>So, first of all, for those of you who've been living under a rock, too, here's what all this chattering is about:</p>

<p>In 2004 Apple added the <a href="http://weblogs.mozillazine.org/hyatt/archives/2004_07.html#005890">search input type</a>, a proprietary variant of the <code>input tag</code> to WebCore. Besides the new <code>type</code> there are additional attributes: <code>incremental</code> (features spotlight-like incremental searching), <code>placeholder</code> (is displayed as long as the widget is left alone), <code>autosave</code> and <code>results</code> (both used for a "recent searches" drop-down).</p>

<p>The syntax looks like this:</p>

<pre><code>&lt;input type="search" placeholder="Search" autosave="your.domain.name" results="5" /></code></pre>

<p>And it will render like this (when unfocused/focused):</p>

<img src="/assets/2007/10/15/safari-search-tag.gif" height="68" title="Safari's search tag looks like this" alt="Safari's search tag tag looks like this" />

<p>Now, what's so <em>cool</em> about this? Aside from looking gorgeous, it adds value in terms of an enhanced user-experience. The usage patterns here are well known, e.g. from browser toolbar search boxes. </p>

<p>So why not just use it? The <em>problem</em>, of course, is that this HTML extension is proprietary. It won't validate, but throw up to four ugly warnings:</p>

<img src="http://www.artweb-design.de/assets/2007/10/15/validation-warnings.gif" height="37" title="Safari's search tag validation fails" alt="Safari's search tag validation fails" />

<h2>Does this really need to be fixed?</h2>

<p>When I redesigned my blog the other day and I included this search tag into the layout, almost immediately a friend of mine came up with a blunt "Hey dude, your markup doesn't validate any more." Oh, my gosh! :)</p>

<p>There are reasonable points about using non-standard-compliant, proprietary extensions. For example <a href="http://swedishcampground.com/2006/11/02/input-typesearch">Random Genius</a> phrased it like this:</p>

<pre><code>&lt;!--
  I know that using type="search" means that my page doesn't validate,
  but for safari users it offers such a nice search experience, and degrades
  nicely for other browsers, that there really is no reason why I shouldn't.
--></code></pre>

<p>... and even <a href="http://blog.fawny.org/2005/06/11/atmedia2005-1a/">Zeldman</a> seems to agree with <a href="http://www.37signals.com/svn/archives2/searchin_safari.php#c4370">Matt's opinion</a> that <em>"there is nothing wrong with proprietary extensions from Apple, Microsoft, whoever as long as the standards are also supported"</em>.</p>

<p>But on the other hand we don't like breaking stuff superfluously either, do we? There's something warm, fuzzy and satisfying about seeing <strong>this</strong> in Safari's status bar:</p>

<img src="/assets/2007/10/15/validation-success.gif" height="37" title="Safari's status bar, no validation errors" alt="Safari's status bar, no validation errors" />

<p>... and to me that's worth a little extra work. So let's see what can be done with some simple, <a href="http://onlinetools.org/articles/unobtrusivejavascript/">unobtrusive Javascript</a> and CSS.</p>

<h2>Check this out</h2>

<p>We're going to:</p>

<ul>
	<li>use a perfectly standard-conform default text input as a search field and give it a class named "search"</li>
	<li>hook into the page load event, find the text input and</li>
	<li>turn it into a Safari search input if Safari is looking at it</li>
	<li>fake the look of the text field if another browser is looking at it</li>
</ul>

<p>For the impatient - here's a simple, working demo of this stuff (be sure to try it in Safari and e.g. Firefox):</p>

<p><a href="http://www.artweb-design.de/demo/safari_search_tag/demo.htm">Demo</a></p>

<p>Ok, let's start with an input tag like this:</p>

<pre><code>&lt;input type="text" class="search" name="q" /></code></pre>

<p>Next we need a way to hook into the page's onload event. Assuming that we've already loaded Prototype.js we'll use this library register the event handler:</p>

<pre><code>Event.observe(window, 'load', beautify_search_inputs);</code></pre>

<p>Once the page is loaded our <code>beautify_search_inputs</code> function will be called. This function iterates over all <code>input</code> tags in the document that have the class name <code>search</code> (mostly, there will be just one such tag). For each of these tags either the method <code>make_search_input</code> or <code>fake_search_input</code> will be called - depending on the browser type.</p>

<pre><code>
function beautify_search_inputs() {
  isSafari = (navigator.userAgent.indexOf("Safari") > 0)
  elements = document.getElementsByClassName('search', null, 'input')
  for (var i = 0; i &lt;elements.length; i++) {
    if (isSafari) { 
      make_search_input(elements[i])
    } else { 
      fake_search_input(elements[i])
    }
  }
}	
</code></pre>

<p>That means, if we're on Safari, the input tag will simply be turned into a type="search" input tag:</p>

<pre><code>
function make_search_input(element) {
  element.type = 'search'
  element.setAttribute('placeholder', element.value);
  element.setAttribute('autosave', 'my.domain.name');
  element.setAttribute('results', '5');
}	
</code></pre>

<p>For every other browser we'll at least try to partially fake Safari's look:</p>

<p>To achieve this we'll wrap it into a <code>div</code>, add <em>two more</em> <code>div</code> tags for the round endings (to allow a dynamic adjustment of the width) and hook up event handlers for the focus and blur events (to add that typical glowing blue focus):</p>

<pre><code>
function fake_search_input(element) {
  Event.observe(element, 'click', function() { 
  	if (element.value == 'Search') element.value = '' })
  Event.observe(element, 'focus', function() { 
  	element.parentNode.className = 'search-container search-active' })
  Event.observe(element, 'blur',  function() { 
  	element.parentNode.className = 'search-container' })

  container = document.createElement('div')
  container.className = 'search-container'
  container.style.width = element.clientWidth + 'px'
  left = document.createElement('div')
  left.className = 'search-left'
  right = document.createElement('div')
  right.className = 'search-right'

  element.parentNode.insertBefore(container, element)
  element.parentNode.removeChild(element)
  container.appendChild(left)
  container.appendChild(right)
  container.appendChild(element)
}	
</code></pre>

<p>Of course these three additional <code>div</code> tags are a bit ugly. But I haven't been able to come up with a more elegant way that also dynamically resizes the <code>div</code>s <em>and</em> works in several browsers.</p>

<p>There you have it.</p>

<ul>
<li>Your page validates.</li>	
<li>Safari users get the full proprietary Apple coolness.</li>
<li>All the other major browsers get a nice fake.</li>
<li>With Javascript turned of nothing happens at all and the widget "degrades" nicely to its pure input tag form.</li>
</ul>

<h2>How to install</h2>

<p>You can find the source here:</p>

<pre><code><a href="http://http://svn.artweb-design.de/stuff/html/safari_search_tag/">http://svn.artweb-design.de/stuff/html/safari_search_tag/</a></code></pre>

<p>After downloading you'll probably want to integrate this stuff into existing CSS and Javascript files (if you're not using an <a href="/2007/4/13/rails-plugin-blazing-fast-page-loads-through-bundled-css-and-javascript">asset bundler</a>, that is)</p>

<p>Pay attention to either put the image <code>safari_search_tag.png</code> in your /images folder or change the CSS rule in <code>safari_search_tag.css</code> accordingly.</p>

<h2>Problems? Anything that can be done better?</h2>

<p>Like I said this version relies on Prototype.js. So if you're not using this library, you'll probably need to use a different way to hook up the onload event handler.</p>

<p>Also, if you're able to create the same visual effect in the same browsers with <em>less</em> additional tags, I'd highly appreciate learning about that.</p>

<p>I've checked this in no other browsers than Safari, IE 6.0, IE 7.0, Opera 9.0 and Firefox 2.0.</p>

<h2>Feedback?</h2>

<p>What do you think?</p>
