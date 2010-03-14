--- 
layout: post
title: "Upcoming Globalize feature: an alternative way of storing model translations"
---
<p>As the title of Saimons blog post mentions this feature deals with a different implementation of model translations. </p>

<p>With Globalize you'd say, for example:</p>

<pre><code>def Page &lt;ActiveRecord::Base
  translates :title
end</code></pre>

<p>Now, traditionally, your database schema would - regardless of how many languages you'd have to deal with in your application - include a <code>pages</code> table with <em>one column</em> named <code>title</code>, right? This column would hold the <em>base_language</em> translations of titles. All other translations would go into a <em>separate table</em> named <code>globalize_translations</code> - a central storage table for all translations of all your "translates-ed" attributes.</p> 

<p>For example, the page <code>title</code> value "I18n the easy way" would be stored directly in the <code>pages</code> table (assuming that English is the <code>base_language</code> of our app). The German translation "I18n leicht gemacht" of this title would go into the <code>globalize_translations</code> table however.</p>

<p>This approach has some obvious advantages like that the translation of your application is entirely separated from the rest of your application/data. But there are some serious drawbacks also, most importantly being less flexible due to the necessity to <code>JOIN</code> in the <code>globalize_translations</code> table. For example, Globalize hasn't been able to support the standard <code>:include</code> and <code>:select</code>behaviour of ActiveRecord (which in turn <span style="text-decoration:line-through;">breaks</span>, ahem, ... disables other ActiveRecord default stuff like <code>has_many :through</code>).</p>

<h2>Enter Saimons Alternative Model Translations ...</h2>

<p>Saimons approach turns things around from a traditional Globalize perspective. His alternative implementation of  <code>ActiveRecord::Base#translates</code>:</p>

<ul>
	<li>requires you to store your translations directly in the model tables on the one hand but</li>
	<li>allows you to leverage all the <code>ActiveRecord::Base::find</code> functionality you're used to without any restrictions on the other hand (such as not being able to use :include and :select in the traditional approach)</li>
</ul>

<p>As Saimon told me you'll be able to switch this behaviour on by putting Globalize::DbTranslate.keep_translations_in_model = true in your environment.rb. But you'll also be able to overwrite this per model, in class scope: self.keep_translations_in_model = true.</p>

<p>To store the translation data directly in the model table you have to have a column per supported language per translated attribute. That is, for the <code>title</code> attribute above, we'd have three db columns when there are three languages supported:</p>

<pre><code>class CreatePages &lt;ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :title, :string
      t.column :title_de, :string
      t.column :title_fr, :string
    end
  end
end</code></pre>

<p>It's been noted that this might get a bit cumbersome as soon as you've more than very few attributes to translate and very few languages to support. (On the other hand, one might come up with some automation support based on <code>ActiveRecord::Migration</code>s to manage this kind of stuff.) Also, what if you want to add new languages in an entirely dynamic way, e.g. through a web interface? Well, of course, as always ... peoples mileages vary and there's no silverbullet to whatever job you're trying to get done.</p>

<p>What Saimons approach is buying you <strong>is</strong> the removal of a beforehand necessary <code>JOIN</code>. Depending on your situation - that's probably quite <strong>a lot</strong>.</p>

<p>Also, as a side-effect of this all the translations will be pre-loaded with your models, so switching the <code>locale</code> won't result in an additional database hit.</p>

<p>PS: To be honest, I'm writing this after only having <em>read</em> <a href="http://saimonmoore.net/2006/12/1/alternative-implementation-of-globalize-model-translations">Saimons article</a>, the code in the <a href="http://trac.globalize-rails.org/trac/globalize/browser/trunk/lib/globalize/localization/db_translate.rb">Globalize SVN</a> etc. I haven't played around with this myself yet.</p>

<p>I'd love to see your comments though!</p>
