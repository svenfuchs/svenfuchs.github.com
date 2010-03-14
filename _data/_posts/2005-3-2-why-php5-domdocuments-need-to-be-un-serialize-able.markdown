--- 
layout: post
title: Why php5 DomDocuments need to be un/serialize()able
---
<p>(Looks like there's little understanding as to why we would need to do this even on the php xml dev's list. You might want to have a look at <a href="http://news.php.net/php.xml.dev/211">this</a> and, more arrogant, <a href="http://www.derickrethans.nl/month-2004-01.php?item=20040101">this</a> statement.)</p>

<p>The new native dom exension is one of the <a href="http://www.sitepoint.com/article/coming-soon-webserver-near/15" target="_blank">really great news in php5</a> - <b>no doubt</b>. There are many really important usecases and no one would ever want to miss it again! We can easily <a href="http://php.net/dom" target="_blank">read, manipulate, write xml elements</a> and do more really nifty stuff with them. Cool :)</p>

<p>We can also extend the native php DomDocument class to add our <b>own behaviour</b> to it. We've shown just one example in "Template playing with php's Dom". So let's take that example.</p>

<p>Here we use the DomDocument class to parse an html (xml) template and build up a controller tree, that's aligning necessary behaviour (unfortunately, the php dom extension doesn't provide any hooks, e.g. to add our behavior to DomElements). Than we let the controller tree react on some user input (request parameters, ...) and manipulate the DomDocument's elements and data. Afterwards we let DomDocument output the html. </p>

<p>That's great. And in our days of <a href="http://www.sitepoint.com/forums/showthread.php?threadid=123769" target="_blank">1001 different php template engines</a> that usually don't care about <a href="http://www.webstandards.org/" target="_blank">standard-compliance</a> at all: it could <i>probably</i> be a way to bring the php community some inches nearer to recognize and use standards.</p>

<p>But of course: we can't do it this way. Using a template with some more than 50 tags gets <b>terribly slow</b>. With each request php starts up the whole environment from a dark void of nothingness and therefore most of php's greatest template engines like <a href="http://wact.sourceforge.net" target="_blank">Wact</a> or <a href="http://smarty.php.net/" target="_blank">Smarty</a> use some "template-compile" stage and cache the results to files to recreate them later on.</p>

<p>Ok, there are some php <a href="http://wact.sourceforge.net/index.php/TemplateView" target="_blank">templating engines/frameworks</a> out there that go a comparable way - besides from that they don't use php5's native dom support but some own, <b>homegrown stuff</b> to parse their templates. <a href="http://www.xisc.com" target="_blank">Prado</a> is possibly one of the best known of them.</p>

<p><b>Prado</b> builds up each component from its templates and component-definition xml files and caches them. After having done that once, these <b>ready-made components</b> will get fetched from the cache and used. The parsing of the templates and their translation to php objects will be by-passed this way and performance gets considerably faster.</p>

<p>In our experiment striving for a templating engine that uses php5's native dom extension as described <a href="">here</a>, we've tried to get around that limitation that dom objects simply <b><i>can't</i></b> be un/serialized with php's native un/serialize() functions. But there's no simple way around it.</p>

<p>We can save some milliseconds by recovering data that have already been set to our controller tree. But <b>we'll always have to</b> ...</p>

<ul>
<li>lookup and <b>read the template</b> (that's fast, depending on our system) </li>
<li><b>re-create the DomDocument</b> from the template (ok, that's even very fast) and </li>
<li><b>re-create the references</b> pointing from our controllers to the appropriate DomElement (that's worse, depending on the complexity of the template and the needs of our controller).</li>
</ul>

<p>This is a basic problem. It's a serious <b>limitation</b> of possible usecases of the php5's dom extension. We won't ever be able to attach our own behaviour to DomDocument/Element objects unless we are willing to:</p>

<ul>
<li>re-create the references to the DomDocument/Element instances at every request or</li>
<li>throw away the idea of having complete components cached in a ready-made state that can be used to set up the application in a (comparatively) very short time.</li>
</ul>

<p>Conclusion: <b>php5 DomDocuments need to be un/serialize()able</b>.</p>

<p>Let's advocate for it. </p>
