--- 
layout: post
title: Distributed votings using microformats
---
<p>(I also wanted to do it in <a href="http://rubyonrails.com">Ruby on Rails</a>
because I figured that this could fit very well as an exercise for learning Rails.
I've been really, really short on free time which tells me a lot about Rails
and it's power to quickly come up with something working. Rails is definitely
exiting ... but I disgress ;)</p>

<h2>Ok, here we go.</h2>

<p>Well, there's <em>one</em> mega-event this year in Germany: the
<a href="http://fifaworldcup.yahoo.com/06/en/index.html">FIFA World Cup 2006</a>&trade;
(*sigh* yes, it's really a trademark of the FIFA). Of course I've chosen this one for
a first test voting. </p>

<p><strong>So, what's your tip?</strong> Who's gonna make it and win the World Cup?</p>

<p>You know it? Great! Then join in and place your tip (we'll call it a "vote").</p>

<h2>How will this work?</h2>

<p>It will work a little bit different from traditional <a href="http://www.ego4u.com/en/read-on/animals/soccer/worldcup2006/vote">votings</a>
and <a href="http://www.misterpoll.com/1851871507.html/">polls</a>
that ask us to just click a button and in the end nobody knows where the votes
came from. The main difference (and the main purpose of this whole approach)
is: </p>

<p>You'll retain the full <em>control</em> over your vote. It's <em>yours</em> and it will remain yours. :)</p>

<p>You won't go to a website owned by somebody else and click on a button.
You'll use <em>your own</em> homepage or blog to tell the world about your vote.  You
can change it if you like, remove it or leave it where it is. To get your vote
in, you'll tell the voting application to digg your homepage for your vote,
add it to the results and display it.</p>

<p>Telling the application about the vote on your homepage can be done in two
ways:</p>

<ul>
<li><p>Either <strong>you own a blog</strong> that supports
<a href="http://en.wikipedia.org/wiki/Trackback">trackback</a>,
then it's fully sufficient to publish a
<a href="http://microformats.org/wiki/vote-links">VoteLink</a>
(that is, a simple but specially crafted HTML link) anywhere
in a blog article. </p></li>
<li><p>Or you include a so-called <strong><a href="http://en.wikipedia.org/wiki/Webbug">webbug</a></strong>
(which is nothing else than a transparent one-pixel image pulled from the
voting application) into your website and open it up in a web browser that
sends a valid referer string with the request (this will work in all
browsers with the default settings). </p></li>
</ul>

<p>That's it. :)</p>

<p>Either way the voting application will get to know about the URL of your
website. It will read it, find your VoteLink and recognize your vote.
Then it will include it into the results which are displayed on
<a href="http://folksr.artweb-design.de/en/voting/wm2006/winner">my website</a>
and which you in turn can publish as a diagramm on your own site. </p>


<p>Sounds interesting? So let's check it out.</p>

<h2>Place your vote ...</h2>

<p>A <a href="http://microformats.org/wiki/vote-links">VoteLinks</a> has the following format:</p>

<pre>
&lt;a href="http://..." rev="vote-for"&gt;some text&lt;/a&gt;
</pre>

<p>The presence and value of the rev attribute "vote-for" make this HTML tag a microformat
(yes, it's as simple as that). The value of the href attribute, i.e. the URL
the link links to defines <em>what</em> you are voting for, the object of your vote.</p>

<p>You can freely chose what you'd like to use as a body for this link (the "some
text" in the format above). It could be a text, an image or - also - just
nothing.</p>

<p>The voting application provides URLs that can be chosen for VoteLinks,
i.e. that each identify one of the options that are available for a certain
voting. In this case, of course these are the countries that participate in
the worldcup:</p>

<p>So you could use:</p>

<pre>
http://folksr.artweb-design.de/vote/wm2006/winner/brazil
</pre>

<p>... which will tell the application that your favorite is Brazil.</p>

<p>Ok, let's try that out right now. </p>

<p>I'll include the following snippet into this blog post which you could prove by looking at the source. </p>

<pre>
&lt;a href="http://folksr.artweb-design.de/vote/wm2006/winner/brazil"
rev="vote-for">here's my tip: Brazil will make it. Who 
else should? ;)&lt;/a>
</pre>

<p>The link is right here: <a href="http://folksr.artweb-design.de/en/voting/wm2006/winner/brazil"
rev="vote-for">my tip: Brazil will make it. Who else should? ;)</a><img src="http://folksr.artweb-design.de/vote/pixel.gif" /></p>

<p>Now, because this is a blog and <span style="text-decoration: line-through">my blog supports trackback, it will send a
trackback to my voting application and the vote gets included into the
results</span>. [1]</p>

<p>[1] Update: *errrmm* ... ok, well. My brand-new Typo installation apparently refuses to send any trackbacks. So I had to include the webbug here, which worked. For more about the webbug see below.</p>

<h2>... and check the results</h2>

<p>Here's a not-yet-super-nice diagramm published by the application that displays
the current results:</p>

<a href="http://folksr.artweb-design.de/en/voting/wm2006/winner">
<img src="http://folksr.artweb-design.de/en/voting/wm2006/winner/graph/pie.png"
style="border-width: 0px" />
</a>

<p>Now, this actually worked. There's only one vote in the database right now and it originated from this page that you're reading right now. :)</p>

<p>You can't see it from the graph, but when you actually click it (or on the
VoteLink above) you'll see the vote that's included in this blog article
in the list of votes published by the application.</p>

<p>In case you don't own a blog there's a second way to tell the application
about your vote by using the <a href="http://en.wikipedia.org/wiki/Webbug">webbug</a>. </p>

<p>That's equally simple. All you have to do is include the following image tag
anywhere in your websites source code:</p>

<pre>
&lt;img src="http://folksr.artweb-design.de/vote/pixel.gif" />
</pre>

<p>That's a transparent 1x1 pixel. When you open up your site in your browser, the
pixel will get pulled from the application. The application will look for the http
referer URL (which your browser should - and most likely will - send). </p>

<p>You're done. The webbug fullfills the same purpose a blog would do by sending
a trackback: the application gets to know about the URL, look it up, find your
VoteLink and add it to the results.</p>

<p>Different from trackbacks which are processed every time they arrive at the application
a webbug will activate the process of digging your website only once. I decided to imlement
things this way because otherwise every hit would result in a lot of work without any benefit.</p>

<p>In case you've changed your vote and like to update it you can add a arbitrary token
to the webbug URL like this:</p>
<pre>
&lt;img src="http://folksr.artweb-design.de/vote/pixel.gif?12345" />
</pre>
<p>Instead of "12345" you could use any other token. The webbug will active the digging 
process once per unique token - at least that's how this is implemented so far.</p>

<h2>What does <i>not</i> work?</h2>

<p>A lot :)</p>

<style>
.done { text-decoration: line-through; }
</style>
<ul>
<li><span class="done">There are only <strong>two</strong> vote options (i.e. countries you could vote for) right now. They were enough for a rough test. I'll add the remaining soon though.</span> [2]</li>
<li><span class="done">A list of available options is also missing.</span> [2]</li>
<li><span class="done">I'll yet have to integrate this stuff with some kind of CMS. Thus, all off the green links in the header and the faq like section on the bottom-right won't do anything.</span> [3]</li>
<li>The design is really sketchy of course.</li>
</ul>

<p><em>[2] Update: I've now added the missing countries to the database. You're now free to really add a vote of your choice.</em></p>
<p><em>Like mentioned above, the URL schema for VoteLinks is: <code>http://folksr.artweb-design.de/vote/wm2006/winner/[country]</code></em></p>
<p><em>Replace [country] by one of the following: angola, argentina, australia, brazil, costarica, cote-d-ivoire, croatia, czech-republic, ecuador, england, france, germany, ghana, iran, italy, japan, korea_republic, mexico, netherlands, paraguay, poland, portugal, saudi_arabia, serbia-montenegro, spain, sweden, switzerland, togo, trinidad-tobago, tunesia, ukraine, usa</em></p>

<p><em>[3] Update: Done. Integrated with Typo (in a rather rude way, but this will do the job for a while I think).</em></p>

<h2>What's next?</h2>

<p>I have a couple of ideas how to expand this in a useful way. I'm going to
describe them in a follow up posting and implement them subsequently at least
for my own exercise.</p>

<p>In short: Of course <span class="done">the application needs to be <a href="http://www.globalize-rails.org/wiki/">translated</a></span>
the translation needs to be expanded and better explanations/instructions are missing.
A Javascript Widget to quickly click the disired VoteFor Link together (probably allowing to add
an image to the link). RSS feeds would be nice.</p>

<p>Later on an interface to allow people to add and administrate their own
votings. Basic community features probably. The ability to publish the definition of
the voting itself in the same distributed way? (Would <a href="http://microformats.org/wiki/xoxo">XOXO</a> be applicable here?
Something else?) Different types of votings or options to make the
voting behave in different ways. More ways to publish results. Etc.</p>

<p><em>[4] Update: <a href="http://www.artweb-design.de/articles/2006/06/09/real-fun-get-on-rails-with-globalize">Globalize @ work now</a>.</em></p>

<h2>Feedback?</h2>

<p>If you like this, <a style="font-weight: bold;" href="http://digg.com/programming/Distributed_votings_using_microformats_">please digg it</a>!</p>
