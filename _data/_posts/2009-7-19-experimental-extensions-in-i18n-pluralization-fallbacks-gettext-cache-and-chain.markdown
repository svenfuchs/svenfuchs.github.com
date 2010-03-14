--- 
layout: post
title: "Experimental Ruby I18n extensions: Pluralization, Fallbacks, Gettext, Cache and Chained backend"
---
<h1>Backend::Simple &lt; Backend::Base</h1>

In Ruby what is the most obvious, elegant and maintainable pattern to extend an existing class' or object's functionality? No, the answer to that is definitely *not* in using <code>alias_method_chain</code>. It's simply including a module to that class. You probably knew that already ;)

We've done this with the I18n <code>Simple</code> backend before but one needs to extend the <code>Simple</code> backend first in order to then inject additional modules to the inheritance chain so that these modules' methods would be able to call super and find the original implementation.

To make this a bit easier I've moved the original <code>Simple</code> backend implementation to a new <code>Base</code> backend class and simply extend the (otherwise empty) <code>Simple</code> backend class from it (<a href="http://github.com/svenfuchs/i18n/blob/fa6a468f28cdd96c83c8c696591e3040af4efec8/lib/i18n/backend/base.rb">see here</a> and <a href="http://github.com/svenfuchs/i18n/blob/fa6a468f28cdd96c83c8c696591e3040af4efec8/lib/i18n/backend/simple.rb">here</a>). This way you now do not need to extend the <code>Simple</code> backend class yourself but you can directly include your modules into it:

<pre><code>module I18n::Backend::Transformers
  def translate(*args)
    transform(super)
  end

  def transform(entry)
    # your transformer's logic
  end
end

I18n::Backend::Simple.send(:include, I18n::Backend::Transformers)</code></pre>

I have no clue what your <code>Transformers</code> module could do exactly but that's the point about extensible libraries, isn't it? In any case this is simply the pattern that the new, experimental <code>Pluralization</code>, <code>Fallbacks</code>, <code>Gettext</code> and <code>Cache</code> modules use that I wanted to talk about :)

<h1>Pluralization</h1>

Out-of-the-box pluralization for locales other than <code>:en</code> has been recurring requests for the I18n gem. Even though it was easy to extend the <code>Simple</code> backend to plug in custom pluralization logic and there are working backends doing that (e.g. in <a href="http://github.com/joshmh/globalize2">Globalize2</a>) there does not seem to be a point in still rejecting a basic feature like this from being included to I18n.

I've thus added a <code>Pluralization</code> module that was largely inspired by <a href="http://github.com/yaroslav/i18n/tree/lambda">Yaroslav's work</a>. It can be included to the <code>Simple</code> backend (or other compatible backend implementations) and will do the following things:

* overwrite the existing <code>pluralize</code> method
* try to find a pluralizer shipped with your translation data and if so use it
* call super otherwise and use the default behaviour

One can ship pluralizers (i.e. lambdas that implement locale specific pluralization algorithms) as part of any Ruby translation file anywhere in the <code>I18n.load_path</code>. The implementation expects to find them with the key <code>:pluralize</code> in a (newly invented) translation metadata namespace <code>:i18n</code>. E.g. you could store an Farsi (Persian) pluralizer like this:

<pre><code># in locales/fa.rb
{ :fa  => { :i18n => { :pluralize => lambda { |n| :other } } } }</code></pre>

And include the <code>Pluralization</code> module like this:

<pre><code>require "i18n/backend/pluralization"
I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)</code></pre>

We still have to figure out how to actually ship a bunch of default pluralizers best, but you can find a complete list of <a href="http://www.unicode.org/cldr/data/charts/supplemental/language_plural_rules.html" title="Language Plural Rules">CLDR's language plural rules</a> compiled to Ruby <a href="http://github.com/svenfuchs/i18n/blob/e4ce5e58f0524ae7c34ca94971363e13aa889f36/test/fixtures/locales/plurals.rb">here</a> (part of ours test suite).

<h1>Locale Fallbacks</h1>

Another feature that was requested quite often, too, is Locale fallbacks. <code>Simple</code> backend just returns a "translation missing" error message or raises an exception if you tell it so. It won't check any other locales if it can't find a translation for the current or given locale though.

There were proposals for a <a href="https://rails.lighthouseapp.com/projects/8994/tickets/2637-patch-i18n-look-up-a-translation-with-the-default-locale-when-its-missed-with-another-specific-locale">minimal fallback functionality</a> that just checks the default locale's translations if a translation is not available for the current locale. <a href="http://github.com/joshmh/globalize2">Globalize2</a> on the other hand ships with a quite powerful Locale fallbacks implementation that also enforces <a href="http://en.wikipedia.org/wiki/IETF_language_tag" title="IETF language tag">RFC 4646/47 standard compliant locale (language) tags</a>.

I've discussed this with Joshua and we've decided to extract a simplified version from <a href="http://github.com/joshmh/globalize2">Globalize2</a>'s fallbacks that makes the <a href="http://tools.ietf.org/html/rfc4646" title="RFC 4646 - Tags for Identifying Languages">RFC 4646</a> standard compliance an optinal feature but still allows enough flexibility to define arbitrary fallback rules if you need them. If you don't define anything it will just use the default locale as a single fallback locale.

Again enabling Locale fallbacks is just a matter of including the module to any compatible backend:

<pre><code>require "i18n/backend/fallbacks"
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)</code></pre>

This overwrites the <code>Base</code> backend's <code>translate</code> method so that it will try each locale given by <code>I18n.fallbacks</code> for the given locale. E.g. for the locale <code>:"de-DE"</code> it will try the locales <code>:"de-DE"</code>, <code>:de</code> and <code>:en</code> until it finds a result with the given options. If it does not find any result for any of the locales it will then raise a <code>MissingTranslationData</code> exception as usual.

The <code>:default</code> option takes precedence over fallback locales, i.e. it will first evaluate a given default option before falling back to another locale.

You can add custom fallback rules to the I18n.fallbacks instance like this:

<pre><code># use Spanish translations if Catalan translations are missing:
I18n.fallbacks.map(:ca => :"es-ES")
I18n.fallbacks[:ca] # => [:ca, :"es-ES", :es, :en]</code></pre>

If you do not add any custom fallback rules it will just use the default locale and the default locales fallbacks:

<pre><code># using :"en-US" as a default locale:
I18n.default_locale = :"en-US"
I18n.fallbacks[:ca] # => [:ca, :"en-US", :en]</code></pre>

If you want RFC 4646 standard compliance to be enforced for your locales you can use the <a href="http://github.com/svenfuchs/i18n/blob/e7bf15351cd2e27f5972eb40e65a5dd6f4a0feed/lib/i18n/locale/tag/rfc4646.rb">Rfc4646 Tag</a> class:

<pre><code>I18n::Locale::Tag.implementation = I18n::Locale::Tag::Rfc4646</code></pre>

This will make a locale "de-Latn-DE-1996-a-ext-x-phonebk-i-klingon" fall back to the following locales in this order:

<pre><code>de-Latn-DE-1996-a-ext-x-phonebk-i-klingon
de-Latn-DE-1996-a-ext-x-phonebk
de-Latn-DE-1996-a-ext
de-Latn-DE-1996
de-Latn-DE
de-Latn
de</code></pre>

Most of the time you probably won't need anything like this. Thus we've used the (much cheaper) <code>I18n::Locale::Tag::Simple</code> class as the default implementation. It simply splits locales at dashes and thus can do fallbacks like this:

<pre><code>de-Latn-DE-1996
de-Latn-DE
de-Latn
de</code></pre>

Should be good enough in most cases, right :)

<h1>Gettext</h1>

The difference between the Gettext support and all the other extensions discussed here is that I haven't had a real use for it myself - so far, so please consider this stuff highly experimental. It shares the fact that people requested it <a href="http://groups.google.com/group/rubyonrails-core/browse_thread/thread/e9e219ff318fa6e7/8952b9da6b107b50">in one way or the other</a> though, so I'd appreciate feedback about it.

Gettext support comes with three parts, only two of them being relevant to the user:

* <a href="http://github.com/svenfuchs/i18n/blob/fa6a468f28cdd96c83c8c696591e3040af4efec8/lib/i18n/helpers/gettext.rb">classical Gettext-style accessor helpers</a>
* <a href="http://github.com/svenfuchs/i18n/blob/fa6a468f28cdd96c83c8c696591e3040af4efec8/lib/i18n/backend/gettext.rb">a Gettext PO file compatible backend storage (currently read-only)</a>
* <a href="http://github.com/svenfuchs/i18n/blob/fa6a468f28cdd96c83c8c696591e3040af4efec8/lib/i18n/gettext.rb">a few internal helpers</a>

To include the accessor helpers to your application you can simply include the module whereever you need them (e.g. in your views):

<pre><code>require "i18n/helpers/gettext"
include I18n::Helpers::Gettext</code></pre>

The backend extension is, again, a matter of including the module to a compatible backend (e.g. <code>Simple</code>):

<pre><code>require "i18n/backend/gettext"
I18n::Backend::Simple.send(:include, I18n::Backend::Gettext)</code></pre>

Now you should be able to include your Gettext translation (\*.po) files to the I18n.load_path so they're loaded to the backend and you can use them as usual:

<pre><code>I18n.load_path += Dir["path/to/locales/*.po"]</code></pre>

Please note that following the Gettext convention this implementation expects that your <em>translation files are named by their locales</em>. E.g. the file <code>en.po</code> would contain the translations for the English locale.

<h1>Translate Cache</h1>

Right from the beginning people <a href="http://groups.google.com/group/rails-i18n/browse_thread/thread/e16079ef9b24d9/d6dbeb958555edbf" title="Quick benchmarks (dramatic results)">benchmarked the I18n gem implementation</a> and compared their numbers against native Hash lookups or other, less rich implementations of <a href="http://github.com/grosser/fast_gettext/blob/2ea5ccb486b1cfd4bacb0c0748db713765b23b9f/README.markdown">similar APIs</a>. Also, <a href="http://github.com/thedarkone">thedarkone</a> has experimented with a <a href="http://github.com/thedarkone/i18n">Fast backend</a> that implements some significant optimizations.

For the I18n gem itself we've refrained from overly extensive "early optimizations" and only applied some tweeks that made the implementation cheaper in obvious ways. This rather conservative approach actually paid out: the clean and readable implementation made the <code>Simple</code> backend refactorings and extensions (like those discussed here) almost trivial.

On the other hand, even though calls to I18n don't actually add <em>that</em> much load to an application sparing resources obviously is an important concern. 

The probably both most effective and least intrusive way of doing that is simply caching all calls to the backend. Again you can include the Cache layer by simply including the module:

<pre><code>require "i18n/backend/cache"
I18n::Backend::Simple.send(:include, I18n::Backend::Cache)</code></pre>

As we do not provide any particular cache implementation though you also have to set your cache to the I18n backend. The cache layer assumes that you use a cache implementation compatible to <a href="http://api.rubyonrails.org/classes/ActiveSupport/Cache.html">ActiveSupport::Cache</a>. If you're using this in the context of Rails this is a matter of one line:

<pre><code>I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)</code></pre>

Obviously this pluggable approach again allows you to pick whatever cache is most appropriate for your setup. For example <a href="http://api.rubyonrails.org/classes/ActiveSupport/Cache.html">ActiveSupport</a> out of the box ships with compatible implementations for plain memory, drb demon and compressed, synchronized and plain memcached storage - wow. These options should be sufficient for 99% of all Rails apps.

Whatever cache implementation you use the I18n backend cache layer will simply cache results from calls to <code>translate</code> (and will do the right thing with MissingTranslationData exceptions raised in your backend).

For that it relies on the assumption that calls to the backend are <a href="http://en.wikipedia.org/wiki/Idempotence" title="Idempotence">idempotent</a>: <em>"A unary operation is called idempotent if, whenever it is applied twice to any value, it gives the same result as if it were applied once."</em>. I18n's library design does not garantuee that by itself but in all practical cases will behave this way unless your doing really weird things with it. Basically, make sure you only pass objects to the translate method that respond to the <a href="http://www.ruby-doc.org/core/classes/Object.html#M000337">hash</a> method correctly. If you use custom lambda translation data make sure they always return the same values when passed the same arguments.

<h1>Chained backend</h1>

The <code>Chain</code> backend is another feature ported from <a href="http://github.com/joshmh/globalize2">Globalize2</a>. It can be used to chain multiple backends together and will check each backend for a given translation key.

This is useful when you want to use standard translations with a <code>Simple</code> backend but store custom application translations in another backends. E.g. you might want to use the <code>Simple</code> backend for managing <a href="http://github.com/svenfuchs/rails-i18n">Rails' internal translations</a> (like ActiveRecord error messages) but use a database backend for your application's translations.

To use the <code>Chain</code> backend you can instantiate it and set it to the I18n module. You can then add chained backends through the initializer or backends accessor:

<pre><code># preserves an existing Simple backend set to I18n.backend
I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)</code></pre>

The implementation assumes that all backends added to the <code>Chain</code> implement a lookup method with the same API as <code>Simple</code> backend does.

<h1>Cool, what's next?</h1>

If you're interested in any of these features, please try these things out and provide some feedback on the <a href="http://groups.google.com/group/rails-i18n">rails-i18n mailinglist</a>. They might make it into the next I18n gem release or not depending on the amount of "real world feedback" we've gotten until then.

Also, by now there's <strong>ton</strong> of good stuff that uses or extends I18n to do useful things with it on <a href="http://github.com/search?language=rb&amp;q=i18n&amp;repo=&amp;type=Repositories">Github</a>. I've collected a few things that I found particular suited for being evaluated, maybe merged and potentially included to I18n here: <a href="http://gist.github.com/149905">Interesting I18n repositories</a>.

I've also done some work on my i18n-tools repository recently, so you hopefully you can expect some news from that front, too.

<h1>Shameless plug</h1>

In case you find this stuff useful I'm always happy to receive another recommendation on <a href="http://www.workingwithrails.com/person/9963-sven-fuchs" title="Ruby on Rails developer: Sven Fuchs from Germany, Berlin">working-with-rails</a> :)
