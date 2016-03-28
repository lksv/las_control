function initMap() {
  $('#placeForm').submit(function() { return false; })

  var input = document.getElementById('placeAutocomplete');
  if (!input) {
    return;
  }

  // google places autocomplete wrong badly when initialize more then one
  // ..or when we are disabling/enabling them?
  // Remove entire element helps well
  input.parentNode.replaceChild(input.cloneNode(true), input);
  var input = document.getElementById('placeAutocomplete');

  var options = {
    types: ['geocode'],
    componentRestrictions: {country: 'cz'}

  };

  autocomplete = new google.maps.places.Autocomplete(input, options);
  autocomplete.addListener('place_changed', onPlaceChanged);


  function onPlaceChanged() {
    var place = autocomplete.getPlace();
    if (place && place.geometry) {
      map.panTo([place.geometry.location.lat(), place.geometry.location.lng()]);
      map.setZoom(18);
      //map.setZoom(15);
    } else {
      document.getElementById('placeAutocomplete').placeholder = '';
    }
  }

};

function initMapTabReinit() {
  // reinitialize google places autocomplete when activete #search tab
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
   if ($(e.target).attr('href') == '#search') {
     initMap();
   }
  });
}

$(document).on("page:change", initMap);
$(document).on("page:change", initMapTabReinit);
