// see https://github.com/twbs/bootstrap/issues/1768
// and https://github.com/bkuhn/copyleft-guide/commit/476a42bf0d737e13a561dbaf6f4e1e91a333e80d
var shiftWindow = function() { scrollBy(0, -70) };
window.addEventListener("hashchange", shiftWindow);
function initAnchorScroll() { if (window.location.hash) shiftWindow(); }
$( document ).ready(function() {
  setTimeout(function() { initAnchorScroll(); });
});
