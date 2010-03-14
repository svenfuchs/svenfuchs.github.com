--- 
layout: post
title: "Ruby on Rails Plugin: WillPaginate Liquidized"
---
<p>This plugin allows you to use <a href="http://rock.errtheblog.com/will_paginate" title="will_paginate">will_paginate</a> with <a href="http://www.liquidmarkup.org/" title="Liquid Templating language">Liquid templates</a>.</p>

<p>I originally wrote this for my <a href="http://www.artweb-design.de/projects/mephisto-plugin-paged-article-lists" title="Mephisto Plugin: Paged Article Lists - artweb design">Mephisto Paginated Article Lists plugin</a> when Mephisto moved to will_paginate for pagination. But of course this is useful in any situation where you want to use will_paginate within Liquid templates, so I pulled it into a plugin of its own.</p>

<p>Currently there are two versions:</p>

<ul>
<li><a href="http://svn.artweb-design.de/stuff/rails/will_paginate_liquidized/tags/will_paginate_r413/">will_paginate_r413</a> works with old will_paginate versions</li>
<li><a href="http://svn.artweb-design.de/stuff/rails/will_paginate_liquidized/tags/will_paginate_r436/">will_paginate_r436</a> is compatible to the <a href="http://errtheblog.com/posts/69-paginatin-christmas" title="Paginatin' Christmas &mdash; err.the_blog">new Chrismas 07 will_paginate version</a></li>
</ul>

<p>You can install them like this:</p>

<pre><code>
script/plugin install http://svn.artweb-design.de/stuff/rails/will_paginate_liquidized/tags/will_paginate_r413/	
script/plugin install http://svn.artweb-design.de/stuff/rails/will_paginate_liquidized/tags/will_paginate_r436/	
</code></pre>

<p>As for the <strong>newer version</strong> you can use it like follows.</p>

<p>Assign a will_paginate collection as a template variable as usual. Then, in your template, filter this collection through the will_paginate Liquid filter. E.g.:</p>

<pre><code>
@posts = Post.paginate :page => params[:page]
Liquid::Template.parse('{{users | will_paginate}}').render({'posts' => @posts})	
</code></pre>

<p>To specify a base path (or URL) for the links that are created, assign it to a will_paginate_options template variable, like so:</p>

<pre><code>
assigns = {'posts' => @posts, 'will_paginate_options' => {:path => '/posts'}
Liquid::Template.parse('{{users | will_paginate}}').render(assigns)	
</code></pre>

<p>This is necessary because Liquid won't grant access to objects like the request object that ActionView templates have access to and that will_paginate relies on. So, we have to assign the path from the controller, which actually makes sense from a Liquid perspective.</p>

<p>Also, you can assign the usual will_paginate options this way. E.g. you can change the prev/next link texts using something like this:</p>

<pre><code>
'will_paginate_options' => {:prev_label => '&amp;larr; older posts'
                            :next_label => 'newer posts &amp;rarr;' }
</code></pre>

<p>Please refer to the <a href="http://rock.errtheblog.com/will_paginate/classes/WillPaginate/ViewHelpers.html" title="Module: WillPaginate::ViewHelpers">will_paginate documentation</a> for a full list of options.</p>

