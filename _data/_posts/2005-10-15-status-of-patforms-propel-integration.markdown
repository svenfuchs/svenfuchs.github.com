--- 
layout: post
title: Status of patForms/Propel integration
---
<p>Propel's extended api has been cleaned up. These changes are currently in Propel's SVN directory which is available at:</p>

<p><a href="http://svn.phpdb.org/propel/">http://svn.phpdb.org/propel/</a></p>

<p>Propels Trac (which is used as Propel's homepage also, including docs, howtos etc) is here:</p>

<p><a href="http://propel.phpdb.org/trac/">http://propel.phpdb.org/trac/</a></p>

<p>These changes will also be in the next release of Propel which is supposed to come soon. By "extended api" I mean the methods that are being added when you enable addGenericAccessors and addGenericMutators at build time:</p>

<pre># in the projects build.properties file
propel.addGenericAccessors = true
propel.addGenericMutators = true</pre>

<p>This will add methods like fromArray(), toArray() etc. to your Object classes and these methods will be used by patForms.</p>

<p>patForms on the other side has included several new classes that allow to integrate with Propel. For example there are the new classes patForms_Definition_Propel, patForms_Storage_Propel etc. as well as some new patForms_Rule_* classes.</p>

<p>You can find the latest version of patForms also in SVN which is here:</p>

<p><a href="http://www.php-tools.net/svn/patForms/trunk">http://www.php-tools.net/svn/patForms/trunk</a></p>

<p>And the patForms bug tracker can be found here:</p>

<p><a href="http://trac.php-tools.net/patForms">http://trac.php-tools.net/patForms</a></p>

<p>This stuff is currently undergoing some "real-life" implementations so we hope to recieve some more feedback from serious users than we've had by now in future. </p>

<p>If you've checked this code out and gathered experience with it, probably discovered any flaws or bugs or have any suggestions or enhancements, please feel free to post to the bug trackers linked above or email me privately.</p>
