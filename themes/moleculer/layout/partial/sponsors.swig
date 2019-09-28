{% if site.data.sponsors.patreon %}
    <h2 class="section-title">Patreon backers &amp; sponsors</h2>
    {% for level in site.data.sponsors.patreon %}
        <h3 class="section-title">{{ level.name }}</h3>
        <div class="support-backers">
            {% for user in level.users %}
                {% if div_remain(loop.index0, 3) == 0 %}
                    </div>
                    <div class="support-backers">
                {% endif %}
                <a href="{{ user.link || '' }}" {% if user.company %} class="company-logo"{% else %} class="user-logo"{% endif %} target="_blank">
                    <img src="{{ user.logo }}" alt="{{ user.name }}" />
                    {% if !user.company %}
                        <label>{{ user.name }}</label>
                    {% endif %}
                </a>
            {% endfor %}
        </div>
    {% endfor %}
{% endif %}
