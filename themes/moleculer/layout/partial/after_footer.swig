<!-- Scripts -->
<!-- build:js build/js/main.js -->
{{ js('js/lang_select') }}
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
<script type="text/javascript" src="https://cdn.jsdelivr.net/docsearch.js/1/docsearch.min.js"></script>
<script type="text/javascript">
document.getElementById('search-input-wrap').classList.add('on');
docsearch({
  apiKey: '{{ config.algolia[page.lang].api_key }}',
  indexName: '{{ config.algolia[page.lang].index_name }}',
  inputSelector: '#search-input'
});
</script>
{% endif %}

<!-- Particles -->
{{ js('js/particles') }}

<script type="text/javascript">
particlesJS("particles-js", {
  "particles": {
    "number": {
      "value": 60,
      "density": {
        "enable": true,
        "value_area": 800
      }
    },
    "color": {
      "value": "#ffffff"
    },
    "shape": {
      "type": "circle",
      "stroke": {
        "width": 0,
        "color": "#000000"
      },
      "polygon": {
        "nb_sides": 5
      },
      "image": {
        "src": "img/github.svg",
        "width": 100,
        "height": 100
      }
    },
    "opacity": {
      "value": 0.1,
      "random": false,
      "anim": {
        "enable": false,
        "speed": 1,
        "opacity_min": 0.1,
        "sync": false
      }
    },
    "size": {
      "value": 6,
      "random": false,
      "anim": {
        "enable": false,
        "speed": 40,
        "size_min": 0.1,
        "sync": false
      }
    },
    "line_linked": {
      "enable": true,
      "distance": 150,
      "color": "#ffffff",
      "opacity": 0.1,
      "width": 2
    },
    "move": {
      "enable": true,
      "speed": 0.5,
      "direction": "none",
      "random": false,
      "straight": false,
      "out_mode": "out",
      "bounce": false,
      "attract": {
        "enable": false,
        "rotateX": 600,
        "rotateY": 1200
      }
    }
  },
  "interactivity": {
    "detect_on": "canvas",
    "events": {
      "onhover": {
        "enable": false,
        "mode": "repulse"
      },
      "onclick": {
        "enable": false,
        "mode": "push"
      },
      "resize": true
    },
    "modes": {
      "grab": {
        "distance": 400,
        "line_linked": {
          "opacity": 1
        }
      },
      "bubble": {
        "distance": 400,
        "size": 40,
        "duration": 2,
        "opacity": 8,
        "speed": 3
      },
      "repulse": {
        "distance": 200,
        "duration": 0.4
      },
      "push": {
        "particles_nb": 4
      },
      "remove": {
        "particles_nb": 2
      }
    }
  },
  "retina_detect": true
});
</script>

<!-- fastclick -->
<script src="//cdnjs.cloudflare.com/ajax/libs/fastclick/1.0.6/fastclick.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
  FastClick.attach(document.body)
}, false)
</script>

<!-- Gitter Chat -->
<script>
  ((window.gitter = {}).chat = {}).options = {
    room: 'ice-services/moleculer'
  };
</script>
<script src="https://sidecar.gitter.im/dist/sidecar.v1.js" async defer></script>