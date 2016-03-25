function initMap() {
  $('#placeForm').submit(function() { return false; })

  var input = document.getElementById('placeAutocomplete');
  if (!input) {
    return;
  }
  var options = {
    types: ['geocode'],
    componentRestrictions: {country: 'cz'}

  };

  autocomplete = new google.maps.places.Autocomplete(input, options);
  autocomplete.addListener('place_changed', onPlaceChanged);


  function onPlaceChanged() {
    var place = autocomplete.getPlace();
    if (place.geometry) {
      map.panTo([place.geometry.location.lat(), place.geometry.location.lng()]);
      map.setZoom(18);
      //map.setZoom(15);
    } else {
      document.getElementById('placeAutocomplete').placeholder = '';
    }
  }
}

$(document).on("page:change", initMap);
//google.maps.event.addDomListener(window, 'load', initMap);
