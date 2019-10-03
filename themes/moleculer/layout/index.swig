<header id="banner" class="wrapper">
  <div class="inner">
    <h1 id="banner-title">{{ page.headline }}</h1>
    <h2 id="banner-subtitle">{{ page.subtitle }}</h2>
    <div id="banner-version">
      <img src="https://img.shields.io/npm/v/moleculer.svg"/>
    </div>

    <div id="banner-start">
      <span id="banner-start-command">npm install moleculer</span><a id="banner-start-link" href="{{ page.site.data.menu.docs }}"><i class="fa fa-arrow-right"></i></a>
    </div>
    <div id="banner-badges">{{ partial('partial/badges') }}</div>
    <div id="banner-share">{{ partial('partial/share') }}</div>
    <div id="banner-donate">{{ partial('partial/donate') }}</div>
  </div>
</header>
<div id="content-wrap">
  <div class="wrapper">
    <div class="inner">

      {{ page_anchor(page.content) }}

      <div style="text-align: center">
        <a href="{{ page.site.data.menu.docs }}">
            <img src="/images/main-example.png" style="width: 100%;height: auto;max-width: 800px;" />
        </a>
      </div>

      <div id="intro-get-started-wrap">
        <a href="{{ page.site.data.menu.docs }}" id="intro-get-started-link">{{ __('index.get_started') }}</a>
      </div>
    </div>
    {{ partial('partial/companies') }}
  </div>
</div>

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
