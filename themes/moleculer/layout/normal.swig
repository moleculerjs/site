<div id="content-wrap">
  <div id="content" class="wrapper">
	<article class="article-container" itemscope itemtype="http://schema.org/Article">
        <div class="article-inner">
            <div class="article">
                <div class="inner">
                    <header class="article-header">
                        <h1 class="article-title" itemprop="name">{{ page.title }}</h1>
                        <h3 class="article-subtitle" itemprop="name">{{ page.subtitle }}</h3>
                    </header>
                    <div class="article-content" itemprop="articleBody">

                        {{ page_anchor(page.content) }}
                    </div>
                </div>
            </div>
            <aside id="article-toc" role="navigation">
                <div id="article-toc-inner">
                    <strong class="sidebar-title">{{ __('page.contents') }}</strong>
                    {{ toc(page.content, {list_number: false, max_depth: 3}) }}
                    <a href="#" id="article-toc-top">{{ __('page.back_to_top') }}</a>
                </div>
            </aside>
        </div>
	</article>
  </div>
</div>
