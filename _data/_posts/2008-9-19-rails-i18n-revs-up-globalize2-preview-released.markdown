--- 
layout: post
title: "Rails I18n revs up: Globalize2 preview released!"
---
<p style="padding:10px;background-color: #efefef;border: 1px solid #555;">
Please note: the following explanations assume that you're familiar with the <a href="http://www.artweb-design.de/2008/7/18/the-ruby-on-rails-i18n-core-api">new I18n API in Rails</a> and might leave some unanswered questions otherwise :-). Also note that this is a preview release targeted at Rails I18n developers. We'll do at least one more release and provide more complete documentation about how Globalize2 can be used by end users then.
</p>

<h2>Globalize2 preview</h2>

<p>The first preview release of Globalize2 includes the following features and tools. Most of them can be used independent of each other so you can pick whatever tools you need and combine them with other libraries or plugins.</p>

<ul>
<li><strong>Model translations</strong> &#8211; transparently translate ActiveRecord data</li>
	<li><strong>Static backend</strong> &#8211; swap the Simple backend for this more powerful backend, enabling custom pluralization logic, locale fallbacks and translation value objects</li>
	<li><strong>Locale LoadPath</strong> &#8211; easily load translation data from standard locations enforcing conventions that suite your needs</li>
	<li><strong>Locale Fallbacks</strong> &#8211; make sure your translation lookups fall back transparently through a path of alternative locales that make sense for any given locale in your application</li>
	<li><strong>Translation value objects</strong> &#8211; access useful meta data information on the translations returned from your backend and/or translated models</li>
</ul>

<p>Also, we've put together a small and simple demo application for demonstrating Globalize2's feature set. You can find <a href="http://github.com/joshmh/globalize2-demo">globalize2-demo</a> on GitHub. Instructions for installation are included in the readme at the bottom of that page.</p>

<p>The implementation of Globalize2 has been sponsored by the company <a href="http://best-group.eu"><em>BEST</em>Group consulting and software</a>, Berlin.</p>

<h2>Installation</h2>

<p>To install Globalize2 with its default setup just use:</p>

<pre><code>
script/plugin install -r 'tag 0.1.0_PR1' git://github.com/joshmh/globalize2.git
</code></pre>
<p>This will:</p>

<ul>
<li>activate model translations</li>
	<li>set I18n.load_path to an instance of Globalize::LoadPath</li>
	<li>set I18n.backend to an instance of Globalize::Backend::Static</li>
</ul>

<h2>Configuration</h2>

<p>You might want to add additional configuration to an initializer, e.g. config/initializers/globalize.rb</p>

<h2>Model translations</h2>

<p>Model translations (or content translations) allow you to translate your models&#8217; attribute values. E.g.</p>

<pre><code>
class Post &lt; ActiveRecord::Base
  translates :title, :text
end
</code></pre>

<p>Allows you to translate values for the attributes :title and :text per locale:</p>

<pre><code>
I18n.locale = :en
post.title # Globalize2 rocks!
I18n.locale = :he
post.title # ?????????2 ????!
</code></pre>

<p>In order to make this work you currently need to take care of creating the appropriate database migrations manually. Globalize2 will provide a handy helper method for doing this in future.</p>

<p>The migration for the above Post model could look like this:</p>

<pre><code>
class CreatePosts &lt; ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.timestamps
    end
    create_table :post_translations do |t|
      t.string     :locale
      t.references :post
      t.string     :title
      t.text       :text
      t.timestamps
    end
  end
  def self.down
    drop_table :posts
    drop_table :post_translations
  end
end
</code></pre>

<h2>Globalize::Backend::Static</h2>

<p>Globalize2 ships with a Static backend that builds on the Simple backend from the I18n library (which is shipped with Rails) and adds the following features:</p>

<ul>
  <li>It uses locale fallbacks when looking up translation data.</li>
	<li>It returns an instance of Globalize::Translation::Static instead of a plain Ruby String as a translation.</li>
	<li>It allows to hook in custom pluralization logic as lambdas.</li>
</ul>

<h2>Custom pluralization logic</h2>

<p>The Simple backend has its pluralization algorithm baked in hardcoded. This algorithm is only suitable for English and other languages that have the same pluralization rules. It is not suitable for, e.g., Czech though.</p>

<p>To add custom pluralization logic to Globalize&#8217; Static backend you can do something like this:</p>

<pre><code>
@backend.add_pluralizer :cz, lambda{|c| 
  c == 1 ? :one : (2..4).include?(c) ? :few : :other 
}
</code></pre>
<h2>Locale Fallbacks</h2>

<p>Globalize2 ships with a Locale fallback tool which extends the I18n module to hold a fallbacks instance which is set to an instance of Globalize::Locale::Fallbacks by default but can be swapped with a different implementation.</p>

<p>Globalize2 fallbacks will compute a number of other locales for a given locale. For example:</p>

<pre><code>
I18n.fallbacks[:"es-MX"] # =&gt; [:"es-MX", :es, :"en-US", :en]
</code></pre>

<p>Globalize2 fallbacks always fall back to</p>

<ul>
<li>all parents of a given locale (e.g. :es for :"es-MX"), </li>
	<li>then to the fallbacks&#8217; default locales and all of their parents and </li>
	<li>finally to the :root locale.</li>
</ul>

<p>The default locales are set to [:"en-US"] by default but can be set to something else. The root locale is a concept borrowed from <a href="http://unicode.org"><span class="caps">CLDR</span></a> and makes sense for storing common locale data which works as a last default fallback (e.g. "ltr" for bidi directions).</p>

<p>One can additionally add any number of additional fallback locales manually. These will be added before the default locales to the fallback chain. For example:</p>

<pre><code>
fb = I18n.fallbacks
fb.map :ca =&gt; :"es-ES" 
fb[:ca] # =&gt; [:ca, :"es-ES", :es, :"en-US", :en]
fb.map :"ar-PS" =&gt; :"he-IL" 
fb[:"ar-PS"] # =&gt; [:"ar-PS", :ar, :"he-IL", :he, :"en-US", :en]
fb[:"ar-EG"] # =&gt; [:"ar-EG", :ar, :"en-US", :en]
fb.map :sms =&gt; [:"se-FI", :"fi-FI"]
fb[:sms] # =&gt; [:sms, :"se-FI", :se, :"fi-FI", :fi, :"en-US", :en]
</code></pre>

<h2>Globalize::LoadPath</h2>

<p>Globalize2 replaces the plain Ruby array that is set to I18n.load_path by default through an instance of Globalize::LoadPath.</p>

<p>This object can be populated with both paths to files and directories. If a path to a directory is added to it it will look up all locale data files present in that directory enforcing the following convention:</p>

<pre><code>
I18n.load_path &lt;&lt; "#{RAILS_ROOT}/lib/locales" 
# will load all the following files if present:
lib/locales/all.yml
lib/locales/fr.yml
lib/locales/fr/*.yaml
lib/locales/ru.yml
lib/locales/ru/*.yaml
...
</code></pre>

<p>One can also specify which locales are used. By default this is set to "*" meaning that files for all locales are added. To define that only files for the locale :es are added one can specify:</p>

<pre><code>
I18n.load_path.locales = [:es]
</code></pre>

<p>One can also specify which file extensions are used. By default this is set to ["rb", "yml"] so plain Ruby and <span class="caps">YAML</span> files are added if found. To define that only *.sql files are added one can specify:</p>

<pre><code>
I18n.load_path.extensions = ['sql']
</code></pre>

<p>Note that Globalize::LoadPath &#8220;expands&#8221; a directory to its contained file paths immediately when you add it to the load_path. Thus, if you change the locales or extensions settings in the middle of your application the change won&#8217;t be applied to already added file paths.</p>

<h2>Globalize::Translation classes</h2>

<p>Globalize2&#8217;s Static backend as well as Globalize2 model translations return instances of Globalize::Translation classes (instead of plain Ruby Strings). These are simple and lightweight value objects that carry some additional meta data about the translation and how it was looked up.</p>

<p>Model translations return instances of Globalize::Translation::Attribute, the Static backend returns instances of Globalize::Translation::Static.</p>

<p>For example:</p>

<pre><code>
I18n.locale = :de

# Translation::Attribute
title = Post.first.title  # assuming that no translation can be found:
title.locale              # =&gt; :en
title.requested_locale    # =&gt; :de 
title.fallback?           # =&gt; true

# Translation::Static
rails = I18n.t :rails     # assuming that no translation can be found:
rails.locale              # =&gt; :en
rails.requested_locale    # =&gt; :de 
rails.fallback?           # =&gt; true
rails.options             # returns the options passed to #t
rails.plural_key          # returns the plural_key (e.g. :one, :other)
rails.original            # returns the original translation with no values 
                          # interpolated to it (e.g. "Hi {{name}}!")
</code></pre>

<h2>Other notes</h2>

<p>Please note that the Globalize2 Static backend (just like the Simple backend) does not support reloading translation data.</p>







