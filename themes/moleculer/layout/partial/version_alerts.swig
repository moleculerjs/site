{% if isOlderVersion() %}
<div class="alert version">This version has reached end-of-life. It is no longer maintained. For the latest stable version, <a href="{{ page.site.data.menu.docs }}">click here.</a></div>
{% endif %}

{% if isNewerVersion() %}
<div class="alert version">You are viewing documentation of a beta release that is currently undergoing final testing before its official release. For the latest stable version <a href="{{ page.site.data.menu.docs }}">click here.</a></div>
{% endif %}

