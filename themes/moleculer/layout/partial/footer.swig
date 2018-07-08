<footer id="footer" class="wrapper">
  <div class="inner">
    <div id="footer-copyright">
      Copyright &copy; 2016-{{ moment(Date.now()).year() }} <a href="https://github.com/icebob" target="_blank">{{ config.author }}</a><br>
      Documentation licensed under <a href="http://creativecommons.org/licenses/by/4.0/" target="_blank">CC BY 4.0</a>.
    </div>
    <div id="footer-links">
      <a href="https://gitter.im/{{ config.github }}" class="footer-link" target="_blank"><i class="fa fa-comments-o"></i></a>
      <a href="https://twitter.com/{{ config.twitter }}" class="footer-link" target="_blank"><i class="fa fa-twitter"></i></a>
      <a href="https://github.com/{{ config.github }}" class="footer-link" target="_blank"><i class="fa fa-github-alt"></i></a>
      <a href="https://stackoverflow.com/{{ config.stackoverflow }}" class="footer-link" target="_blank"><i class="fa fa-stack-overflow"></i></a>
    </div>
  </div>
</footer>
