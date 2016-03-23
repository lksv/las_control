// global definition :(
// decode query string params and puts it to global params variable

function decodeQParams() {
  window.params = {};
  window.location.href.replace(/#.*/, '').replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
    params[decodeURIComponent(key)] = decodeURIComponent(value);
  });
}
