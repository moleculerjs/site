{% if isOlderVersion() %}
<div class="alert version">What you are currently viewing is the documentation of an old version. For the latest stable version <a href="{{ page.site.data.menu.docs }}">click here.</a></div>
{% endif %}

{% if isNewerVersion() %}
<div class="alert version">What you are currently viewing is the documentation of a new beta version. For the latest stable version <a href="{{ page.site.data.menu.docs }}">click here.</a></div>
{% endif %}

