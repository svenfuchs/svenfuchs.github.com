--- 
layout: post
title: Finally. Ruby on Rails gets internationalized
---
<p>In hindsight we've initially tried to accomplish way to much. Everybody
brought their experience and thinking about "good I18n practices" to the table
- which proved extremely valuable because it forced everbody to push their own
horizon. But it also resulted in something that would have been "just another
Rails I18n solution" ... build right into Rails. As such it would not have
fully satisfied every one of us. Too heavyweight, too complicated, just too
much of everything.</p>

<p>So with the beginning of 2008 our work slowed down, good new ideas kept
popping up but eventually the project completely stalled and people focussed
on other business. Apparently we needed a creative break. </p>

<p>Then in May we went back to the drawing board and came up with a fresh
approach based on our previous experience. Now all of a sudden we were able to
agree on a very slim and minimal implementation of our concepts that covers
all of our requirements: it works as a Ruby gem and is suited not only for use
in Rails, it adds only minimal load to Rails core and it still implements the
common api that will allow I18n solutions to build on.</p>

<p>To me this project already proved extremely interesting and educating.
Almost all of the ideas that are now implemented have been already present in
our discussions last year. But even though we've went through lots of lots of
discussions we initially just haven't been able to shave the whole yak fur
down to this minimal level.</p>

<p>I guess all of us learned a great deal about I18n. In fact some of us
(including me) completely changed their minds about what's useful, good
practice and common need ... and more importantly: what really can be
omitted.</p>

<h2>So, what's in the box? And what's not?</h2>

<p>First of all, there still won't be a fullblown one-fits-all I18n/L10n
solution in Rails. Please, understand that. Rails still won't be able to
translate your application to your language as long it's not very similar to
US English.</p>

<p>Instead, Rails continues to be what it always was: a framework
<em>localized to <code>en-US</code></em>. But this time with a twist: it is
also internationalized.</p>

<p>That means: all hardcoded message strings and logic that we've previously
been monkey patching in all of our plugins are now abstracted out of the Rails
core code (which we mean by the process of "internationalization") and stored
in a central place, accessible through a common interface.</p>

<p>We worked hard to stick to the principle of doing "the simplest thing that
ever could work" with this. Rails itself won't provide means to localize an
application to anything else than <code>en-US</code>. Instead it ships with a
solution that gets the job done and walks away.</p>

<p>Rails will ship with our I18n Ruby gem which consists of two parts: </p>

<ul>
<li>The first part is the API itself which is just a Ruby module with a bunch
of methods that will be used by Rails and delegate all requests to a
backend.</li>
<li>The second part is the Simple backend which implements whatever is
necessary to re-localize Rails back to <code>en-US</code>.</li>
</ul>

<p>The Simple backend acutally <em>might</em> also work for simple
localization tasks such as translating an error message to another language,
but, really, that's a side effect.</p>

<h2>So what do we win?</h2>

<p>The whole point of the exercise is: the Simple backend can be swapped with
a different implementation that supports the same API. Future Rails I18n
plugins will do exactly that.</p>

<p>E.g. there certainly will be backends that provide different pluralization
rules, more powerful means to localize dates and numbers, persist translations
in other formats (e.g. Gettext files or in the database). There might be
backends that themselves provide some kind of a framework to support pluggable
extensions and custom solutions for certain locales etc.</p>

<p>So if we still need to rely on plugins for our fullblown L10n support, what
do we win then?</p>

<p>The short answer: A lot!</p>

<p>In the past I18n developers implemented their solutions for the same
problems again and again. Our repeatedly reinvented wheels came with different
flavours of syntax sugar and different <a href="http://www.bikeshed.com/"
title="Why Should I Care What Color the Bikeshed Is?">bikeshed colors</a> of
monkey patches. The latter repeatedly broke when Rails moved by a millimeter
and plugin developers had to fix their stuff.</p>

<p>I'm not saying that this situation was all bad. Actually I really believe
that it was necessary for Rails' ecosystem to experiment with all of these
solutions. But we've arrived at a point where we can move on.</p>

<p>So with this patch applied Rails I18n developers can now build on what was
extracted from former experience. Instead of reimplementing things over and
over again they can focus on some of the more challenging features like
localized inflections, special formattings for strings, dates, numbers
etc.</p>

<p>We also hope that future solutions will be more exchangeable and
pluggable. There hopefully won't be the need to stick to a certain solution
anymore just because it's the only one supporting inflections for a certain
locale. Or the only one with a strong Gettext backend. Or whatever special
feature comes to mind.</p>

<p>Of course that's still a long road ahead. But we believe that this step,
the merge of the work of the "Rails I18n group", will help a lot on the
journey.</p>

<h2>Get involved!</h2>

<p>If you'd like to join us working on Ruby on Rails's future I18n support, provide
feedback or ask questions please do so! You can find our Google Group over at
<a href="http://groups.google.com/group/rails-i18n" title="rails-i18n | Google
Groups">http://groups.google.com/group/rails-i18n</a>.</p>

<p>This solution was developed by the Rails I18n group consisting of 
<a href="http://railsontherun.com">Matt Aimonetti</a>,
<a href="http://www.workingwithrails.com/person/759-joshua-harvey">Joshua Harvey</a>,
<a href="http://saimonmoore.net">Saimon Moore</a>,
<a href="http://www.arkanis-development.de">Stephan Soller</a> and 
myself, 
with the additional work, help and feedback of many other Rails I18n developers 
including
<a href="http://tore.darell.no/">Tore Darell</a>,
Chris Eppstein,
<a href="http://www.lucaguidi.com">Luca Guidi</a> 
<a href="http://www.samlown.com">Samuel Lown</a>
<a href="http://www.markin.net">Yaroslav Markin</a>,
<a href="http://workingwithrails.com/person/5064-joshua-sierles">Joshua Sierles</a>,
<a href="http://julik.nl/">Julian 'Julik' Tarkhanov</a>
and others.</p>
