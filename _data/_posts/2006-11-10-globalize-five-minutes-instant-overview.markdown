--- 
layout: post
title: Five minutes instant overview - Get on Rails with Globalize! Part 1 of 8
---
<p>This article is part of my series "<a href="http://www.artweb-design.de/articles/2006/11/10/get-on-rails-with-globalize-comprehensive-writeup">Get on Rails with Globalize</a>". At the end of this article you'll find a summary of what will be discussed in the next article of this series.</p>

<h2>Start your engines, please!</h2>

<p>You'll need to have a working Rails app up and running to check things out. If you start a fresh Rails app from scratch make sure that your conf/database.yml knows about your database, valid credentials etc. and everything else is nice.</p>

<p>Now, make your way to your Rails app directory and <strong>install the plugin</strong> from the Globalize Subversion repository. (Take care to choose the right version. As of writing there's a branch for Rails 1.1 while trunk is <i>not</i> compatible with 1.1.)</p>

<pre>
script/plugin install svn://svn.globalize-rails.org/globalize/
branches/for-1.1
</pre>

<p>And if you're keen to keep your stuff straight you'll probably want to rename the directory:</p>

<pre>
mv vendor/plugins/for-1.1 vendor/plugins/globalize
</pre>

<p>Now just do:</p>

<pre>
rake globalize:setup
</pre>

<p>... and you're already done with the setup!</p>

<p><em>(If you're curious, check your database! You'll find three new globalize_* tables with 239 countries, 186 languages and 3420 pre-translated strings ... including several languages I'd bet you've never heard of like <a href="http://en.wikipedia.org/wiki/Avar_language">Avar</a>, <a href="http://en.wikipedia.org/wiki/Manx_language">Manx</a> or <a href="http://en.wikipedia.org/wiki/Wolof_language">Wolof</a>!)</em></p>


<h2>Configuring Globalize</h2>

<p>That's it. You're globalized now. Welcome to the club :-)</p>

<p>There's nothing more to do than include the library and <strong>set the base_language</strong> for your Globalize instance.</p>

<p>In environment.rb this should do the job:</p>

<pre>
Rails::Initializer.run do |config|
  # ...
end
include Globalize # put this here
Locale.set_base_language('en-US') # and here :-)
</pre>

<p>Don't forget to restart your server after changing the environment.rb file in case it's already running.</p>

<p>You're done.</p>

<p>The meaning of the <code>base_language</code> is that this language is what Globalize treats as the "primary" language - which means that data stored in your model tables is stored in the primary language whereas translations are stored in the <code>globalize_translations</code> table.</p>

<p>Joshua Harvey explains it like this:</p>

<p>[In the database] <em>"... base language entries are stored in the parent table itself, as opposed to the <code>globalize_translations</code> table. So if you have a table called '<code>products</code>', and your base language is English, the English product name would be stored in <code>products.name</code>, whereas the German translation would be stored in <code>globalize_translations</code>."</em></p>

<p>And thus: <em>"It's important to never change the base language once you've started populating the database."</em> So choose your <code>base_language</code> carefully.</p>


<h2>Dates, Time, Numbers: a question of form</h2>

<p>Already impatient to check out some working stuff? I were, too ...</p>

<p>There's a nice example in the Globalize wiki using <a href="http://www.globalize-rails.org/globalize/show/example">Rails Unit tests and fixtures</a>. For now we'll check things out on the console. So, fire up your console (i.e., within your Rails app directory, do: script/console).</p>

<p>The <a href="http://globalize.rubyforge.org">api documentation</a> for <strong><a href="http://globalize.rubyforge.org/classes/Globalize/CoreExtensions/Time.html#M000010">Time.localize</a></strong>() says that this method <em>"acts the same as <code>strftime</code>, but returns a localized version of the formatted date/time string"</em>.</p>

<p>Ok, let's check that out:</p>

<pre>
>> Time.now.localize("%d. %B %Y")
</pre>

<p>which should give you:</p>

<pre>
=> "21. June 2006"
</pre>

<p>You're probably not overly surprised about this. ;-) But in fact this means that Globalize is already at work here. The string "June" comes from the Globalize database tables and represents the English full name of, well, the month June as requested by <code>%B</code>.</p>

<p>So let's try to change the current language setting to something else, say: Spanish. I have no idea if this format would actually be used in Spain but you get the point:</p>

<pre>
>> Locale.set("es-ES")
>> Time.now.localize("%d. %B %Y")
=> "21. Junio 2006"
</pre>

<p>(Beware that the pre-translated data that Globalize is coming with is not complete. For example when you try the same example with the German locale <code>de-DE</code> than instead of the expected "21. Juni 2006" you'd actually get "21. June 2006" because the German translation is missing so far.)</p>

<p>You can format Integers, Floats, Dates, Times with <code>localize</code>. Just like <code>Time.localize</code>, <code>Date.localize</code> mimics <code>strftime</code>'s behaviour.</p> 

<p>When you call <code>localize</code> on an Integer it will return <em>"the integer in String form, according to the rules of the currently active locale"</em> - and the same applies to Floats:</p>

<pre>
>> Locale.set("de-DE")
>> 123456.localize # format an Integer
=> 123.456
>> 123.456.localize # format a Float
=> 123,456
</pre>

<p>Also, you can use the alias <code>loc</code> instead of <code>localize</code> for convenience.</p>


<h2>ViewTranslations: Time for .t</h2>

<p>What's the most basic purpose of I18n tools? It's the ability to translate arbitrary text, isn't it? Text that belongs to the application tier itself and most likely won't change that often once the application is out of the door: view templates, mail templates, error messages, flash notices, ... hardcoded stuff mostly.</p>

<p>Globalize adds a new method <code>translate</code> to Rubys String and Symbol classes that will do all the heavy lifting for this type of translation (which is called "ViewTranslation" internally). Also, there's an alias <code>t</code> so that your templates don't get too cluttered.</p>

<p>Let's see that in action ...</p>

<pre>
>> Locale.set("de-DE")
>> "Welcome".t
=> "Welcome"
</pre>

<p>What the heck? We'd expect to see the result "Willkommen" here, wouldn't we? This doesn't seem to work, right? Well, actually, it does.</p>

<p>We need to provide Globalize with the translation of "Welcome" first of course (and we'll do so in short - so stay tuned). You'll most probably develop your Rails application in one (base) language and add your translations afterwards.</p>

<p>Besides that this perfectly demonstrates Globalize's behaviour when it encounters a string that it doesn't know yet:</p>

<ol style="list-style-type: lower-alpha">
<li>Instead of throwing an error it will simply return the original string and</li>
<li>it will remember the string for you by dumping it into the database (so you can look it up later).</li>
</ol>

<p>If you're curious go and look up the globalize_translations table. You'll find that there's a new record for the key "Welcome" - waiting for translation. Globalize remembers strings that are used in your application by dumping them in the database:</p>
                                                                                                                                                                                                                                                              
<pre>
>> Translation.find(:first, :order => "id DESC")
=> #&lt;Globalize::ViewTranslation:0x275c410 @attributes={ ...
   "tr_key"=>"Welcome", "text"=>nil, 
   "type"=>"ViewTranslation", ...}>
</pre>

<p>(In case you expected a method <code>_()</code> like that's common in classic gettext libraries: yes, you can use that one, too. Globalize adds a (although deprecated) method <code>_()</code> to Rubys Object class so you can call it "globally" and in turn it will call <code>Locale.translate</code> then.)</p>


<h2>How to add ViewTranslations</h2>

<p>Ok, let's teach Globalize how to welcome people in German. That's as simple as:</p>

<pre>
Locale.set("de-DE")
Locale.set_translation('Welcome', 'Willkommen')
</pre>

<p>Or alternatively:</p>

<pre>
lang = Language.pick('de-DE')
Locale.set_translation('Welcome', lang, 'Willkommen')
</pre>

<p>So finally Globalize will come up with:</p>

<pre>
>> Locale.set("de-DE")
>> "Welcome".t
=> "Willkommen"
</pre>

<p>Of course in your templates, you'd use something like this:</p>

<pre>
&lt;%= "Welcome".t -%>
</pre>

<p>Now, that's <em>waaay</em> cool ... really. Think about it for a moment: Globalize lets you append .t to any string which will transparently lookup and find available translations. In case there's no translation available it will simply return the original string (which seems to be the default behaviour most t10n/i18n tools show). As soon you've added a translation it will be used.</p>


<h2>ModelTranslations? Just add hot water ...</h2>

<p>Now, so far that's basically about date formats and static strings like those in your templates. What about your models, you wonder?</p>

<p>Globalize comes with the capability to transparently translate any attribute of your ActiveRecords Models ... all you have to do is add a <code>translates</code> directive to your model class like this:</p>

<pre>
def Page &lt; ActiveRecord::Base
  translates :title
end
</pre>

<p>As soon as there actually is a translation for the title attribute in the database it will be used - otherwise, like above, the base language's value will be used by default. (Also, an empty record will be saved to the database so that you can check back for strings that need to be translated).</p>

<p>Now how do you tell Globalize about a model translation? Simply by saving the model. Like this:</p>

<pre>
Locale.set('en-US')
page = Page.create!(:title => 'Welcome to Globalize!')

Locale.set('de-DE')
page.reload # we'd get a Globalize::WrongLanguageError here w/o this
page.title = 'Willkommen bei Globalize!'
page.save
</pre>

<p>Ok, cool. Let's sum things up.</p>

<p>You'll need two fingersnips to get your Rails app globalized: install the Globalize plugin and use it :-). Using it is as simple as 1-2-3, too:</p>

<ol>
<li>There's <code>.t</code> for ViewTranslations (arbitrary, static text),</li>
<li>there's the <code>translates</code> directive for ModelTranslations (ActiveRecord) and</li>
<li>there's <code>.loc</code> to localize your date, time and number formats.</li>
</ol>

<h2>And of course there's more ...</h2>

<p>So much for the basics.</p>

<p>Of course there's much more to discuss. In Part 2 of the series <a href="/articles/2006/11/10/get-on-rails-with-globalize-comprehensive-writeup">"Get on Rails with Globalize"</a> we'll talk about <a href="/articles/2006/12/03/some-common-questions-on-getting-started-get-on-rails-with-globalize">Some common questions on getting started</a> like:</p>

<ul>
	<li>How to setup your application to use Unicode</li>
	<li>How to select and persist the current user's locale</li>
	<li>How to translate Rails ActiveRecord messages</li>
	<li>How to localize entire templates</li>
</ul>
