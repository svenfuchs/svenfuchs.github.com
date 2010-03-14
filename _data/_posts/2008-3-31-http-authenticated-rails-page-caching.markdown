--- 
layout: post
title: Http-authenticated Rails page caching
---
<h2>Request-response cycle for HTTP authenticated page caching</h2>

<p>So, let's have a look at how the request/response cycle would have to look like in order to teach our Rails stack HTTP authenticated page caching.</p>

<p>Usually, with page caching, when a GET request is handled by Rails for the first time Rails saves the response body to a file in the servers document root (usually public/) before it returns it to the frontend server. That's all about it. For subsequent requests to the same path the frontend server would notice that this file exists and immediately serve it to the client without passing the request to Rails at all. </p>

<p>That means that Rails has no chance to authenticate the user and return a "<code>401 Unauthorized</code>" header if necessary. Thus the most important tweak for HTTP authenticated page caching is to teach the frontend server to ask Rails whether or not a file may be served to the client with the given credentials (i.e. request headers).</p>

<p>This actually is not a new idea and has been done for other environments before. For example <a href="http://www.modperl.com/book/chapters/ch6.html#Access_Control_with_I_mod_perl_">Apache mod_perl</a> allows to do the same and I'm sure there are lots of similar solutions. The basic concept is to configure the frontend server to (instead of using static configuration like an <a href="http://httpd.apache.org/docs/2.0/mod/mod_auth.html" title="mod_auth - Apache HTTP Server">.htaccess</a> file or a more performant <a href="http://httpd.apache.org/docs/2.0/mod/mod_auth_dbm.html" title="mod_auth_dbm - Apache HTTP Server">DBM database</a>, in case of Apache) ask an arbitrary backend to authenticate the request.</p>

<p>So, for the sake of simplicity the first goal here is to configure Mongrel (as a frontend server for this experiment) to ask the Rails application to authenticate the request when a request to a certain location comes in.</p>

<p>So, lets say we have a realm of private documents and our Rails app handles requests to the private/ path with a PrivateController. Page caching is turned on so Rails saves the response from the index action of this controller to the file public/private.html. </p>

<p>We now want Mongrel to not immediately serve that file but instead ask Rails to authenticate it with the given request headers. If Rails authenticates the request Mongrel should serve the file. If not Mongrel should return a 401 response with no body.</p>

<p>The appropriate HTTP method for "asking" such things to a RESTful service is HEAD (if I by all means understand the HTTP specs correctly, please correct me if I'm wrong). Thus, we'd also need to teach Rails a new bit of knowledge about page caching: that it doesn't need to re-build an already existing page-cached file when a HEAD request to it comes in.</p>

<h2>An experimental implementation</h2>

<p>It turns out that these things are pretty easy to implement. Mongrel is just Ruby and Rails is greatly extensible anyways. The Rails handler in Mongrel relies on a CGIWrapper which is tagged "still very alpha" and "ugly but does the job" in the Rdoc comments. But anyways, that doesn't hold us back from using and extending this stuff.</p>

<p>In order to keep this blog post shorter I've <a href="http://svn.artweb-design.de/stuff/rails/authenticated_page_caching/" title="Revision 441: /stuff/rails/authenticated_page_caching">uploaded my experimental implementation</a> so can look at the code and I can omit it from the text here. You can install it as a usual Rails plugin and then run Mongrel like this:</p>

<pre><code>
mongrel_rails start -S vendor/plugins/authenticated_page_caching/mongrel.rb
</code></pre>

<p>This loads the mongrel.rb file as a config script which gets executed while Mongrel is starting up. This file defines the class RailsAuthHandler which implements the behaviour explained above. Also, at the bottom of the file you find the lines:</p>

<pre><code>
auth = RailsAuthHandler.new(rails)
auth.location '/private'
uri "/", :handler => auth, :in_front => true
</code></pre>

<p>This just registers the RailsAuthHandler instance as a handler and specifies that it needs to be called before other handlers (i.e. before Mongrel's default Rails handler).</p>

<p>When a request comes in with a PATH_INFO that matches what we have specified as auth.location (of course we could specifiy more that one location) it will intercept things and pass a HEAD request to Rails like discussed above. Depending on Rails' response the handler will accordingly save the file or pass through 401 and 404 headers. </p>

<p>If a request does not match any of the registered locations the handler won't do anything but just return and let Mongrel call the next handler which is the default Rails handler.</p>

<p>So we can now set up a controller like this:</p>

<pre><code>
class PrivateController &lt; ApplicationController
  prepend_before_filter :authenticate
  caches_page :index

  def index
    render :text => "some private content"
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic('Private stuff!') do |user, pass|
        user == "user" &amp;&amp; pass == "pass" 
      end
    end
end  
</code></pre>

<p>This is basically common ground. We need to use <code>prepend_before_filter</code> instead of <code>before_filter</code>. This way <code>authentication</code> gets called before the <code>serve_page_cached_file</code> filter which already has bee <a href="http://svn.artweb-design.de/stuff/rails/authenticated_page_caching/lib/authenticated_page_caching/action_controller.rb" title="">registered by the plugin</a> and teaches Rails to serve an existing page cached file instead of re-rendering and re-saving it. </p>

<p>I'm unsure about the details of the implementation of the <code>serve_page_cached_file</code> filter but for this purpose it does its job.</p>

<h2>Show time</h2>

<p>Now let's try this out. We have to make sure that Rails caching is turned on so either start Mongrel in production mode or set <code>config.action_controller.perform_caching</code> to true in <code>config/environments/development.rb</code>. Also, make sure that no public/private.html file exists, yet.</p>

<p>With Mongrel started with our extension we can try things out like follows (I've stripped some of the returned lines from the responses for brevity):</p>

<pre><code>
$ curl http://localhost:3000/private -I
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="This is private stuff!"
Status: 401 Unauthorized
</code></pre>

<p>This is what we'd also get without our handler. The file doesn't exist, yet, and thus Rails gets called. Because Rails can't authenticate the request (we haven't specified any username and password) we receive a 401 response.</p>

<p>(Something I don't understand is the "Content-Length: 27" header that's also included in the response. What does this refer to?)</p>

<p>Ok, so let's try to authenticate:</p>

<pre><code>
$ curl http://localhost:3000/private -I --user user:pass
</code></pre>

<p>Rails responds:</p>

<pre><code>
HTTP/1.1 200 OK
ETag: "47f11a41-15-1ccce4"
Last-Modified: Mon, 31 Mar 2008 17:07:13 GMT
Content-Length: 21
</code></pre>

<p>... with the body "some private content\n" which now also has been saved to the file public/private.html:</p>

<pre><code>
$ stat -f "%Sm %N" public/private.html 
Mar 31 21:24:10 2008 public/private.html  
</code></pre>

<p>Now, with usual page caching Mongrel would serve the page cached file on subsequent requests even if no credentials have been provided. But with our extension it doesn't, but instead asks Rails for authentication, which fails. We get the same response as above:</p>

<pre><code>
$ curl http://localhost:3000/private -I
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="This is private stuff!"
Status: 401 Unauthorized
</code></pre>

<p>Also, even though Rails is called with a HEAD request it doesn't re-render the index action of the PrivateController. Instead, the ActionController just looks for an existing file public/private.html and uses that to determine the content-length header which will be set accordingly for the response to the HEAD request.</p>

<pre><code>
$ stat -f "%Sm %N" public/private.html 
Mar 31 21:24:10 2008 public/private.html  
</code></pre>

<p>... the same as above. Also, for subsequent requests the last-modified header doesn't change.</p>

<h2>Ok, so what?</h2>

<p>One question I've been asked when discussing this stuff on Euruko was "Great, but how is this different from action caching?". That's a great question because different from usual page caching Rails will be called here of course. So where's the advantage? </p>

<p>The main advantage I see is that with this approach we actually use the HTTP protocol itself to implement the authentication mechanism: we just send a HEAD request to Rails. And a HEAD request is a well-known, specified thing that many applications can understand.</p>

<p>This in some way decouples the cache from Rails a bit more: with this in place we could easily switch to another backend to have our requests authenticated. Maybe just a plain-old .htaccess-style config. Or some LDAP server that both the frontend server and the Rails backend can talk to.</p>

<p>Also, and maybe this is the more important point, it's no big deal to imagine some simple caching mechanism implemented in the fronend layer. The authenticating response from Rails is <strong>just another HTTP response</strong>! And HTTP has means to communicate caching metadata build in - so we can easily cache that on the frontend as well. </p>

<p>For example, we could have Mongrel (in this case) store the responses to the authenticating HEAD requests to Memcache. We could either just cache them according to given HTTP headers (say, for a couple of minutes) or we could even have our Rails application expire (sweep) these memcached responses as necessary.</p>

<p>Of course you won't seriously want to use Mongrel as your only frontend server. That's right :) I've just implemented this proof-of-concept thing as a Mongrel extension because for me this was the <a href="http://c2.com/cgi/wiki?DoTheSimplestThingThatCouldPossiblyWork" title="Do The Simplest Thing That Could Possibly Work">simplest thing</a> that could possibly work.</p>

<p>For getting the most out of this approach we'd need an extension for our "real" frontend server like Nginx, Lighttpd, Apache or whatever we use. My last experiences coding C/C++ are like 10 years old so I'm not particulary eager to play with this. (From what I've read on the Nginx wiki extensions shouldn't be too hard to do, though).</p>

<p>On the other hand a Mongrel extension like this should work with a another server in front of it assuming it's configured accodingly. One could have (e.g.) Nginx serving static files for all locations except for the http-authenticated ones, Mongrel serving http-authenticated static files and Rails creating them. I imagine that this already would allow for a great boost for authenticated files even though Mongrel is not the best choice for serving static files.</p>

<p>Also, with some further tweaking this of course should allow to authenticate page cached files through other, e.g. cookie-based authentication mechanisms, too. (So, yes, you could even think of funky stuff like OpenID authenticated page caching as jokingly suggested by a <a href="http://twitter.com/mislav" title="Twitter / mislav">jumping man</a> at Euruko. ;)</p>

<h2>Any ideas?</h2>

<p>Although this experimental implementation seems to work quite well there's still a lot of questions to answer and stuff to work on.</p> 
  
<p>E.g. is my assumption correct or wrong that using a HEAD in this way is the right way to integrate the communication of the frontend server and the backend Rails application? What would be the best way to (e.g.) memcache Rails' responses in Mongrel? Do you have an idea how to implement this stuff as an Nginx extension (or as an extension for another good frontend server)? Have you got HTTP authentication working with Ajax for all most important browser versions?</p>

<p>I'd greatly appreciate feedback on this. So, let me know what you think :)</p>
