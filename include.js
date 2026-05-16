// Simple client-side include loader for static sites
(function () {
  function loadInclude(el) {
    var url = el.getAttribute('data-include');
    if (!url) return Promise.resolve();
    return fetch(url).then(function (r) { return r.text(); }).then(function (html) {
      el.innerHTML = html;
      // mark active nav link if present
      var nav = el.querySelector('.site-nav');
      if (nav) {
        var links = nav.querySelectorAll('a');
        var path = location.pathname.split('/').pop() || 'index.html';
        links.forEach(function (a) {
          var href = a.getAttribute('href').split('/').pop();
          if (href === path) a.classList.add('active');
        });
      }
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    var includes = Array.prototype.slice.call(document.querySelectorAll('[data-include]'));
    Promise.all(includes.map(loadInclude)).catch(function (err) { console.error('include.js error', err); });
  });
})();
