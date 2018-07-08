<section>
	<h2 class="section-title">Who is using Moleculer?</h2>

    {% for group in site.data.companies %}
    	<div class="company-list">
            {% for item in group %}
                {% if item.name %}
                    <a href="{{ item.link }}" class="company-logo" target="_blank">
                        <img src="{{ item.logo }}" alt="{{ item.name }}" />
                    </a>
                {% endif %}
            {% endfor %}
    	</div>
    {% endfor %}

	<div class="company-missing">If you don't see here your company, <a href="https://github.com/moleculerjs/moleculer/issues/101" target="_blank">tell us.</a></div>
</section>
