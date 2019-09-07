<!-- Scripts -->
<!-- build:js build/js/main.js -->
{{ js('js/lang_select') }}
{{ js('js/version_select') }}
{{ js('js/scrollingelement') }}
{{ js('js/toc') }}
{{ js('js/mobile_nav') }}
<!-- endbuild -->
<script src="https://cdn.jsdelivr.net/retinajs/1.3.0/retina.min.js" async></script>
{% if page.layout === 'plugins' %}
<!-- Plugin search -->
<script src="https://cdn.jsdelivr.net/lunr/0.6.0/lunr.min.js"></script>
<!-- build:js build/js/plugins.js -->
{{ js('js/plugins') }}
<!-- endbuild -->
{% endif %}
<!-- Algolia -->
{% if config.algolia[page.lang] %}
<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/docsearch.js@2/dist/cdn/docsearch.min.js"></script>
<script type="text/javascript"> docsearch({
apiKey: '7d5514b7c3e161a428f04f33ba1bdab4',
indexName: 'moleculer',
inputSelector: '#search-input',
algoliaOptions: { 'facetFilters': ["version:{{ get_version() }}"] },
debug: false // Set debug to true if you want to inspect the dropdown
});
</script>
{% endif %}

<!-- fastclick -->
<script src="//cdnjs.cloudflare.com/ajax/libs/fastclick/1.0.6/fastclick.min.js"></script>
<script src="https://unpkg.com/medium-zoom@1.0.2/dist/medium-zoom.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    FastClick.attach(document.body)
    mediumZoom('.content img', {
        background: "rgba(0,0,0,0.6)"
    });
}, false)
</script>

<!-- Gitter Chat -->
<script>
  ((window.gitter = {}).chat = {}).options = {
    room: 'moleculerjs/moleculer'
  };
</script>
<script src="https://sidecar.gitter.im/dist/sidecar.v1.js" async defer></script>
