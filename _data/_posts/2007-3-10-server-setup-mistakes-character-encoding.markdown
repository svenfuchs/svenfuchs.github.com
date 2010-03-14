--- 
layout: post
title: "Server config: Mistakes with character encoding - part 2"
---
<h2>Know what your server talks!</h2>

<p>Know its configs and defaults, that is. If you've put a static (say) HTML file on your server, encoded as (say) <code>utf-8</code> and you just can't get it displayed the right way ... look at your server's config.</p>

<p>Here's why.</p>

<p>Many webservers send a content-type HTTP header by default alongside with (e.g.) static HTML files. For example, Apache by default sends this one:</p>

<pre>
Content-Type: text/html; charset=iso-8859-1
</pre>

<p>If there's a content-type HTTP header being send it doesn't matter if you've included a meta-tag in your HTML file, like this one:</p>

<pre>
&lt;meta http-equiv="Content-Type" content="text/html; charset=iso-8859-15">
</pre>

<p>Common browsers will prefer information that's send via HTTP headers over information that's embedded as meta-tags into the document itself. </p>

<p>You might well have put the correct meta-tag onto your page (e.g. declaring that this very document is utf-8 encoded) ... if the server sends a content-type HTTP header along with it that declares it is encoded as <code>latin-1</code> your browser will stick to the HTTP header.</p>

<h2>Among the top candidates: Rails' page caching</h2>

<p>This particular mishap might well catch you when your used to configuring your Ruby on Rails applications but for the first time ever start using Rails' page caching mechanism. Page caching is the only one of <a href="http://ap.rubyonrails.com/classes/ActionController/Caching.html">Rails' caching mechanisms</a> where not Rails but the webserver will send the HTTP headers.</p>

<p>When you've configured Rails to e.g. talk utf-8 to the world, but haven't pay attention to the headers your server is sending they'll most probably differ from the Rails headers.</p>

<p>That is: the first page that's send by Rails will be fine - the browser will know it as <code>utf-8</code> and display everything correctly. Every subsequent request to the same page will be responded with the same data but preceeded by a different content-type header, so the browser will try to display it as <code>latin-1</code> ...</p>

<h2>How to check this?</h2>

<p>To find out what HTTP headers are send for a given file you can just use curl:</p>

<pre>curl -I http://rubyonrails.org</pre> 

<p>... will do the job.</p>

<p>Oh, and if you can't use  here's an <a href="http://web-sniffer.net/">online HTTP header sniffer</a> ... there are various other tools out there, too.</p>

<h2>How to fix this?</h2>

<p>It's usually pretty trivial to change your webservers config to send your stuff with a different content-type header. For example, here's a bunch of useful information about <a href="http://www.w3.org/International/questions/qa-htaccess-charset">overwriting Apache's default encoding with a .htaccess file</a>. For example, in your .htaccess file you could use:</p>

<pre>&lt;Files "*.htm">
ForceType "text/html; charset=UTF-8"
&lt;/Files></pre>

<p>This page contains a <a href="http://mongrel.rubyforge.org/docs/howto.html">howto about configuring Mongrels mime-types</a>. Basically, you add some MIME types to a YAML file like config/mongrel_mime.yml:</p>

<pre>---
.htm: text/html; charset=UTF-8
.html: text/html; charset=UTF-8
.txt: text/plain; charset=UTF-8</pre>

<p>... and then specify this file when you start Mongrel, like this: <code>mongrel_rails start -m config/mongrel.mime.yml [...]</code>.</p>
