<div id="content-wrap">
  <div id="content" class="wrapper">
	<article class="article-container" itemscope itemtype="http://schema.org/Article">
        <div class="article-inner">
            <div class="article">
                <div class="inner">
                    <header class="article-header">
                        <h1 class="article-title" itemprop="name">{{ page.title }}</h1>
                    </header>
                    <div class="article-content" itemprop="articleBody">

                        {{ page_anchor(page.content) }}

                        <!-- Patreon sponsors -->

                        {{ partial('partial/sponsors') }}

                        <!-- Open Collective -->

                        <h2 id="Open-Collective-backers-amp-sponsors" class="article-heading">
                            <a href="#Open-Collective-backers-amp-sponsors" class="headerlink"
                                title="Open Collective backers &amp; sponsors"></a>Open Collective backers &amp; sponsors<a
                                class="article-anchor" href="#Open-Collective-backers-amp-sponsors" aria-hidden="true"></a></h2>
                        <h3 id="Gold-sponsors" class="article-heading"><a href="#Gold-sponsors" class="headerlink"
                                title="Gold sponsors"></a>Gold sponsors<a class="article-anchor" href="#Gold-sponsors" aria-hidden="true"></a>
                        </h3>
                        <p><a href="https://opencollective.com/moleculer" target="_blank" rel="noopener"><img
                                    src="https://opencollective.com/moleculer/tiers/gold-sponsor.svg?avatarHeight=70&width=600"
                                    alt="Become a sponsor"></a></p>

                        <h3 id="Silver-backers" class="article-heading"><a href="#Silver-backers" class="headerlink"
                                title="Silver-backers"></a>Silver-backers<a class="article-anchor" href="#Silver-backers" aria-hidden="true"></a>
                        </h3>
                        <p><a href="https://opencollective.com/moleculer" target="_blank" rel="noopener"><img
                                    src="https://opencollective.com/moleculer/tiers/silver-backer.svg?avatarHeight=70&width=600"
                                    alt="Become a backer"></a></p>

                        <h3 id="Bronze-backers" class="article-heading"><a href="#Bronze-backers" class="headerlink"
                                title="Bronze-backers"></a>Bronze-backers<a class="article-anchor" href="#Bronze-backers" aria-hidden="true"></a>
                        </h3>
                        <p><a href="https://opencollective.com/moleculer" target="_blank" rel="noopener"><img
                                    src="https://opencollective.com/moleculer/tiers/bronze-backer.svg?avatarHeight=70&width=600"
                                    alt="Become a backer"></a></p>


                        <h3 id="Copper-backers" class="article-heading"><a href="#Copper-backers" class="headerlink"
                                title="Copper-backers"></a>Copper-backers<a class="article-anchor" href="#Copper-backers" aria-hidden="true"></a>
                        </h3>
                        <p><a href="https://opencollective.com/moleculer" target="_blank" rel="noopener"><img
                                    src="https://opencollective.com/moleculer/tiers/copper-backer.svg?avatarHeight=70&width=600"
                                    alt="Become a backer"></a></p>

                        <!-- Contributors -->

                        <h2 id="Contributors" class="article-heading"><a href="#Contributors" class="headerlink"
                                title="Contributors"></a>Contributors<a class="article-anchor" href="#Contributors" aria-hidden="true"></a></h2>
                        <p>This project exists thanks to all the people who contribute. [<a
                                href="https://github.com/moleculerjs/moleculer/blob/master/CONTRIBUTING.md" target="_blank" rel="noopener">How
                                to contribute</a>]</p>
                        <div align="center">
                            <a href="https://github.com/moleculerjs/moleculer/graphs/contributors" target="_blank"><img
                                    src="https://opencollective.com/moleculer/contributors.svg?width=890&button=false"></a>
                        </div>

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
            </aside-->
        </div>
	</article>
	<!-- {{ partial('partial/sidebar') }} -->
  </div>
</div>
