<header id="banner" class="wrapper">
  <div class="inner">
    <h1 id="banner-title">{{ page.headline }}</h1>
    <h2 id="banner-subtitle">{{ page.subtitle }}</h2>
    <div id="banner-version">
      <img src="https://img.shields.io/npm/v/moleculer.svg"/>
    </div>

    <div id="banner-start">
      <span id="banner-start-command">npm install moleculer</span><a id="banner-start-link" href="docs/"><i class="fa fa-arrow-right"></i></a>
    </div>
    <div id="banner-badges">{{ partial('partial/badges') }}</div>
    <div id="banner-share">{{ partial('partial/share') }}</div>
  </div>
</header>
<div id="content-wrap">
  <div class="wrapper">
    <div class="inner">
      <ul id="intro-feature-list">
        <li class="intro-feature-wrap">
          <div class="intro-feature">
            <div class="intro-feature-icon"><i class="fa fa-bolt"></i></div>
            <h3 class="intro-feature-title">Blazing fast</h3>
            <p class="intro-feature-desc">High-performance microservices framework. Check our <a href="/docs/benchmark.html">benchmark results</a>!</p>
          </div>
        </li>
        <li class="intro-feature-wrap">
          <div class="intro-feature">
            <div class="intro-feature-icon"><i class="fa fa-diamond"></i></div>
            <h3 class="intro-feature-title">Extensible</h3>
            <p class="intro-feature-desc">All built-in modules (caching, serializer, transporter) are pluggable. You can use your custom solutions.</p>
          </div>
        </li>
        <li class="intro-feature-wrap">
          <div class="intro-feature">
            <div class="intro-feature-icon"><i class="fa fa-code"></i></div>
            <h3 class="intro-feature-title">Open source</h3>
            <p class="intro-feature-desc">Moleculer is 100% open source and free of charge. All source code is available under the MIT License on GitHub.</p>
          </div>
        </li>
        <li class="intro-feature-wrap">
          <div class="intro-feature">
            <div class="intro-feature-icon"><i class="fa fa-heartbeat"></i></div>
            <h3 class="intro-feature-title">Fault tolerance</h3>
            <p class="intro-feature-desc">Moleculer is a fault tolerance framework. It has built-in load balancer & circuit breaker.</p>
          </div>
        </li>
      </ul>
      {{ page.content }}
      <div id="intro-get-started-wrap">
        <a href="docs/" id="intro-get-started-link">{{ __('index.get_started') }}</a>
      </div>
    </div>
    <section>
      <h2 class="section-title">Who is using Moleculer?</h2>
      <div class="company-list">
        <a href="https://www.conciergeauctions.com/" class="company-logo" target="_blank">
          <img src="https://s3.amazonaws.com/media.conciergeauctions.com/logo.jpg" alt="Concierge Auctions" />
        </a>
        <a href="http://www.ingsw.com/" class="company-logo" target="_blank">
          <img src="https://user-images.githubusercontent.com/306521/31340277-edc01780-ad05-11e7-952e-0c959a107a2c.png" alt="ingenious" />
        </a>
        <a href="https://www.thb.co.in/" class="company-logo" target="_blank">
          <img src="https://thehealthybillion.com/images/thb/landingpage/logobig.png" alt="THB" />
        </a>
        <a href="https://zaoblako.ru/" class="company-logo" target="_blank">
          <img src="https://zaoblako.ru/images/zaoblako_l.png" alt="Zaoblako" />
        </a>
      </div>
      <div class="company-missing">If you don't see here your company, <a href="https://github.com/ice-services/moleculer/issues/101" target="_blank">tell us.</a></div>
    </section>
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
