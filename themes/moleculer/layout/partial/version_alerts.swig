{% if isOlderVersion() %}
<div class="alert version">This version has reached end-of-life. It is no longer maintained. For the latest stable version, <a href="{{ page.site.data.menu.docs }}">click here.</a></div>
{% endif %}

{% if isCurrentVersion() %}
<div class="alert version">New release is coming soon! If you want to try out the latest features then run <code>npm i -s moleculer@next</code>. The docs for the latest version are available <a href="{{ page.site.data.menu.docs }}">here.</a>
</div>
{% endif %}

{% if isNewerVersion() %}
<div class="alert version">You are viewing documentation for a beta release that is currently undergoing final testing before its official release. For the latest stable version <a href="{{ page.site.data.menu.docs }}">click here.</a></div>
{% endif %}

