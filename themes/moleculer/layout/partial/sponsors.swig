{% if site.data.sponsors.patreon %}
    <h2 class="section-title">Patreon backers &amp; sponsors</h2>
    {% for level in site.data.sponsors.patreon %}
        <h3 class="section-title">{{ level.name }}</h3>
        <div class="support-backers {{ loop.key }}">
            {% for user in level.users %}
                <a href="{{ user.link || '' }}" {% if user.company %} class="company-logo"{% else %} class="user-logo"{% endif %} target="_blank">
                    <img src="{{ user.logo }}" alt="{{ user.name }}" />
                    {% if !user.company %}
                        <label>{{ user.name }}</label>
                    {% endif %}
                </a>
            {% endfor %}
        </div>
        <a href="https://www.patreon.com/bePatron?u=6245171" data-patreon-widget-type="become-patron-button">Become a Patron!</a><script async src="https://c6.patreon.com/becomePatronButton.bundle.js"></script>

    {% endfor %}
{% endif %}
