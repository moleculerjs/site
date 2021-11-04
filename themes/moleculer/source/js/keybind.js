(function () {
  "use strict";

  document.addEventListener("keydown", (event) => {
    if (event.key === "/" && document.activeElement === document.body) {
      event.preventDefault();
      document.getElementById("search-input").focus();
    }
  });
})();
