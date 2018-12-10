<div id="content-wrap">
  <div id="content" class="wrapper">
	<article class="article-container" itemscope itemtype="http://schema.org/Article">
	<div class="article-inner">
		<div class="article">
		<div class="inner">
			<header class="article-header">
				<h1 class="article-title" itemprop="name">{{ page.title }}</h1>
			</header>
            <a href="https://github.com/moleculerjs/awesome-moleculer">Check our Awesome Moleculer repo!</a>
			<div class="article-content" itemprop="articleBody">
			{% for category in site.data.modules %}
				<h3 id="{{ loop.key }}" class="article-heading">
                    {{ __('modules.' + loop.key) }}
                    <a class="article-anchor" href="#{{ loop.key }}" aria-hidden="true"></a>
                </h3>
				<table>
					<thead>
						<th>Name</th>
						<th>Description</th>
						<th>Author</th>
						<th>Version</th>
					</thead>
					<tbody>
						{% for module in category %}
							<tr>
								<td>
									<a href="{{ module.link }}" target="_blank">{{ module.name }}</a>
								</td>
								<td>{{ module.desc }}</td>
								<td>
									<a href="https://github.com/{{ module.author }}" target="_blank" rel="noopener">
										{{ module.author }}
									</a>
								</td>
								<td>
									<a href="https://www.npmjs.com/package/{{module.name}}" target="_blank" rel="noopener">
										<img src="https://img.shields.io/npm/v/{{module.name}}.svg?maxAge=3600" alt="npm" />
									</a>
								</td>
							</tr>
						{% endfor %}
					</tbody>
				</table>
			{% endfor %}
			{{ page_anchor(page.content) }}
			</div>
			<footer class="article-footer">
			<time class="article-footer-updated" datetime="{{ date_xml(page.updated) }}" itemprop="dateModified">{{ __('page.last_updated', date(page.updated)) }}</time>
			</footer>
		</div>
		</div>
		<!--aside id="article-toc" role="navigation">
			<div id="article-toc-inner">
				<strong class="sidebar-title">{{ __('page.contents') }}</strong>
				{{ toc(page.content, {list_number: false, max_depth: 3}) }}
				<a href="#" id="article-toc-top">{{ __('page.back_to_top') }}</a>
			</div>
		</aside -->
	</div>
	</article>
	{{ partial('partial/sidebar') }}
  </div>
</div>
