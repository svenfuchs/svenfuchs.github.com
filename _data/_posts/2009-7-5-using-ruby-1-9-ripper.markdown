--- 
layout: post
title: "Using Ruby 1.9 Ripper "
---
<p>While Ripper parses your code it continously fires events (or &#8220;calls callbacks&#8221;) when it finds something interesting. There are two types of events: scanner (lexer) and parser events.</p>

<p>The scanner basically goes through the code from the left to the right character by character. When it finds known things (such as a keyword, whitespace or a semicolon) it fires a corresponding even that you can react to. The parser works on a higher level and watches for known Ruby constructs (such as a symbol, a method call or a class definition) and also fires events.</p>

<p>You can check the available events by outputting <code><a href="http://github.com/svenfuchs/ripper2ruby/blob/303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82/notes/scanner_events" title="notes/scanner_events at 303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82 from svenfuchs's ripper2ruby - GitHub">Ripper::SCANNER_EVENTS</a></code> and <code><a href="http://github.com/svenfuchs/ripper2ruby/blob/303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82/notes/parser_events" title="notes/parser_events at 303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82 from svenfuchs's ripper2ruby - GitHub">Ripper::PARSER_EVENTS</a></code>. </p>

<p>You can respond to these events by simply defining methods named <code>:"on_#{event_name}"</code> (omitting the <code>@</code> character for scanner events). As long as you do not mess this up (which you might want to do) the parser always passes the results from the last inner parser events to the current parser event. E.g.:</p>

<pre><code>require 'ripper'

class DemoBuilder &lt; Ripper::SexpBuilder
  def on_int(token) # scanner event
    super.tap { |result| p result }
  end

  def on_binary(left, operator, right) # parser event
    super.tap { |result| p result }
  end
end

src = "1 + 1"
DemoBuilder.new(src).parse
</code></pre>

<p>This outputs:</p>

<pre><code>[:@int, "1", [1, 0]]
[:@int, "1", [1, 4]]
[:binary, [:@int, "1", [1, 0]], :+, [:@int, "1", [1, 4]]]
</code></pre>

<p>When a scanner event is fired you can check the current position (it is passed to the event but you can also always call <code>self.position</code>) which allows for tracking detailled positioning information. Positions are given as [row, column] with the row being 1-based. On parser level events the current position is not very useful (and not passed to your event callbacks) because parser events are fired when the parser recognizes a known ruby construct as completed - i.e. at the end of the construct.</p>

<p>Scanner events are fired &#8220;just so&#8221;, i.e. the scanner finds something and calls your callback method. The return values might or might not be passed to parser events. Parser events otoh build a meaningful tree and their return values are always passed to the next (outer) event. You can generally think of events being fired &#8220;from the inside out&#8221;, starting with lowlevel scanner events.</p>

<p>You can examine the hierarchie of these events by doing:</p>

<pre><code>require "pp"
src = "1 + 1"
pp Ripper::SexpBuilder.new(src).parse
</code></pre>

<p>will output:</p>

<pre><code>
[:program,
 [:stmts_add,
  [:stmts_new],
  [:binary, [:@int, "1", [1, 0]], :+, [:@int, "1", [1, 4]]]]]
</code></pre>

<p>You think of this as a nested method call where the first element of each array is the method name and the rest are the arguments. In the example above there would be 5 method calls. The first <code>:@int</code> call would receive the arguments <code>"1"</code> and <code>[1, 0]</code>, the <code>:binary</code> would receive <code>["1", [1, 0]], :+, ["1", [1, 4]]</code>. The other calls, like <code>:program</code> would not receive any arguments.</p>

<p>When executed the (theoretical) interpreter would first evaluate the innermost arguments, right? That&#8217;s exactly what Ripper does, too. It will first fire the first @int event, then the second one and then pass the return values of these two events (together with the <code>:+</code> operator token) to the next outer method, which is the <code>:binary</code> event in this case.</p>

<p>(&#8220;Theoretical&#8221; of course refers to these particular s-expressions. There are languages that are very much based on exactly this concept, like e.g. Lisp.)</p>

<p>As you can see even though the scanner fires events on whitespace there aren&#8217;t any whitespace characters passed to any of the callbacks. I don&#8217;t know if there&#8217;s anything else happening to these but of course you can define callbacks for the different kinds of whitespace and do something useful with it. The same is true for comments and quite some stuff that doesn&#8217;t make a semantical difference in Ruby (such as parentheses for method calls etc.).</p>

<p>To examine all events in the order they are actually fired you can use the event log that ships with Ripper2Ruby:</p>

<pre><code>
src = "1 + 1"
Ripper::EventLog.out(src)
</code></pre>

<p>will output:</p>

<pre><code>
@int                1
@sp                 " "
@op                 +
@sp                 " "
@int                1
binary
stmts_new
stmts_add
program
</code></pre>

<p>I&#8217;m not an expert here but Ripper&#8217;s s-expressions and events seemed to make more sense to me than ParseTree&#8217;s stuff. Ripper still doesn&#8217;t seem to be completely consistent though. </p>

<p>E.g. for word lists (i.e. Arrays that are defined using <code>%w()</code> syntax) there are different events fired depending whether you have <code>%w()</code> or <code>%W()</code>.</p>

<pre><code>src = '%W(foo bar)'
pp Ripper::SexpBuilder.new(src).parse
</code></pre>

<p>outputs:</p>

<pre><code>
[:program,
 [:stmts_add,
  [:stmts_new],
  [:words_add,
   [:words_add,
    [:words_new],
    [:word_add, [:word_new], [:@tstring_content, "foo", [1, 3]]]],
   [:word_add, [:word_new], [:@tstring_content, "bar", [1, 7]]]]]]
</code></pre>

<p>But on the other hand:</p>

<pre><code>
src = '%w(foo bar)'
pp Ripper::SexpBuilder.new(src).parse
</code></pre>

<p>outputs:</p>

<pre><code>
[:program,
 [:stmts_add,
  [:stmts_new],
  [:qwords_add,
   [:qwords_add, [:qwords_new], [:@tstring_content, "foo", [1, 3]]],
   [:@tstring_content, "bar", [1, 7]]]]]
</code></pre>

<p>As you can see for qwords (i.e. the non-interpolating version) there seems to be a <code>:qwords_add</code> and <code>:qwords_new</code> event missing. I can&#8217;t see any good reason for this.</p>

<p>Also, Ripper seems to get the method call operator wrong when you use <code>"::"</code></p>

<pre><code>
src = "A::b()"
pp Ripper::SexpBuilder.new(src).parse
</code></pre>

<p>outputs:</p>

<pre><code>
[:program,
 [:stmts_add,
  [:stmts_new],
  [:method_add_arg,
   [:call,
    [:var_ref, [:@const, "A", [1, 0]]],
    :".",
    [:@ident, "b", [1, 3]]],
   [:arg_paren, nil]]]]
</code></pre>

<p>Watch the period which should be a <code>:"::"</code> symbol.</p>

<p>In quite some situations I&#8217;ve found the events ambigous or not explicit. E.g. for the closing parentheses in a words list like <code>%w(foo bar)</code> Ripper fires a <code>:@tstring_end</code> event - which is the same event as it fires for closing parentheses in Strings as in <code>%(foobar)</code>.</p>

<p>It gets really weird when you try to build something from the events that Ripper fires for <a href="http://github.com/svenfuchs/ripper2ruby/blob/303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82/test/nodes/heredoc_test.rb" title="test/nodes/heredoc_test.rb at 303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82 from svenfuchs's ripper2ruby - GitHub">Heredocs</a> or even stacked Heredocs combined with method calls on the Heredoc opener token - maybe the most weird Ruby construct anyway. In general though this stuff is fun to work with and quite obvious once you got the idea :)</p>
