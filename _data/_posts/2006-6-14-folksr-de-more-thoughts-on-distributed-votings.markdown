--- 
layout: post
title: folksr.de - more thoughts on distributed votings
---
<h2>1. Add a form to get the votes from a certain url in and immediately see
the results.</h2>

<p>I believe there should be at least one way to get the own votes in by
<em>doing</em> something in a classical or familiar way. Publish something
on your homepage, go  somewhere else, annouce it. That's a process
everybody knows and understands. It's probably some kind of
root-experience with the internet. :) And even if that's to pathetical
than it's at least a fallback mode that will reliably work when the other
stuff fails.</p>

<h2>2. Add some kind of ID to the votes to identify a vote as <em>the
same</em> vote like another</h2>

<p>As soon as any application adds any kind of sh*t ... sorry, parameter
to the URL the vote will be counted more than once - be it something
unRESTy like a SessionID or even my shiny Typo blogging engines URL
layout: It will smash the whole purpose of publishing <strong>one</strong>
vote-for link in one single go.</p>

<p>To stick with the example of my blog: as soon as I don't put the
vote-for link in the "extended" content it will appear on the blog start
page, on the articles details page, and various archive, categories ...
etc. pages.  I think something very similar will apply to practically
every blogging engine out there, won't it?</p>

<p>I yet wonder if using <a href="http://microid.org">MicroID</a> would be
applicable here or if there's something even simpler.</p>

<p>A MicroID is defined as: </p>
<pre>
MicroID = sha1_hex(sha1_hex("mailto:user@email.com") +
  sha1_hex("http://website.com"));
</pre>
<p>which would result in a hash like:
<code>2067da21d6a17c4264c432a0d26535b09cbd6a2f</code> and could be used
as in:</p>
<pre>
&lt;a class="microid-a9993e364706816aba3e25717850c26c9cd0d89d"
  rev="vote-for">&lt;/a>
</pre>

<p>But of course the MicroID seems to be a bit more than what would be
necessary at the <strong>very</strong> least: that would be any unique ID
that's used with a vote-for link. The voting system would simply refuse to
count a link with an ID that's already in the database. Or it (better yet)
would remove the present vote.</p>

<p>This minimum of a unique ID would say: "To make sure that this (one) vote
won't be counted more than once (even if it occures on different URLs) include
this unique ID." No more. This would be the minimum.</p>

<p>The MicroID would furthermore include personal/social identity like in:
"This (link) is the vote-for (option) X like placed by (person) A."</p>


<h2>3. Check out the idea to parse the webservers referrer logs ...</h2>

<p>... or simply check for the presence of a HTTP Referer at <em>any
request</em> and get rid of the webbug stuff if that works.</p>

<p>Heck. Today I wonder why this hasn't occured to me before! :) But it was <a
href="http://suda.co.uk/">Brian Suda</a> who suggested on the microformats mailinglist:</p>

<p><em>"You could just use your referrer log to find inbound
links and then spider just those. The downside is that peole without
traffic would not get their vote in, so the blogger themself would
have to click the link to "activate" the vote. It is sort if the same
effect as your 'webbug' idea without the hassel."</em> Obviously. Thanks,
Brian! :)</p>

<p>I yet have to think about pros/contras for either observing the logs or
spider a page as a reaction on clicks only. Either way the application
would require the user to activate the vote by clicking it AND would
require him to use a browser that sends a valid HTTP referer string.</p>
<p>But both downsides are not really different from what the webbug would
do - just simpler in that they both avoid a separate pixel/image.</p>

