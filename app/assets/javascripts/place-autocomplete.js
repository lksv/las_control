function initMap() {
  $('#placeForm').submit(function() { console.log('canceling form'); return false; })

  var input = document.getElementById('placeAutocomplete');
  if (!input) {
    return;
  }
  var options = {
    types: ['geocode'],
    componentRestrictions: {country: 'cz'}

  };

  //geocoder = new google.maps.Geocoder();
  autocomplete = new google.maps.places.Autocomplete(input, options);
  //var infowindow = new google.maps.InfoWindow();
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

$(document).ready(initMap);
$(document).on("page:load", initMap);
//google.maps.event.addDomListener(window, 'load', initMap);
