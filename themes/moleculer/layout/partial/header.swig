<header id="header" class="wrapper">
  <div id="header-inner" class="inner">
    <h1 id="logo-wrap">
      <a href="{{ url_for_lang('') }}" id="logo">Moleculer</a>
    </h1>
    <nav id="main-nav">
      {{ header_menu('main-nav') }}
      <div id="search-input-wrap" class="on">
        <div id="search-input-icon">
          <i class="fa fa-search"></i>
        </div>
        <input type="search" id="search-input" placeholder="{{ __('menu.search') }}">
        <div class="search-input-keybind">
          <pre>/</pre>
        </div>
      </div>
    </nav>
    <div id="lang-select-wrap">
      <label id="lang-select-label"><i class="fa fa-globe"></i><span>{{ lang_name(page.lang) }}</span></label>
      <select id="lang-select" data-canonical="{{ canonical_path_for_nav() }}">
        {% for lang in site.data.languages %}
          <option value="{{ loop.key }}"{% if page.lang === loop.key %} selected{% endif %}>{{ lang_name(loop.key) }}</option>
        {% endfor %}
      </select>
    </div>
    <a id="mobile-nav-toggle">
      <span class="mobile-nav-toggle-bar"></span>
      <span class="mobile-nav-toggle-bar"></span>
      <span class="mobile-nav-toggle-bar"></span>
    </a>
  </div>
</header>
