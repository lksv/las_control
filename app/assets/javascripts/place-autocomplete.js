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

  function autoCallback(geoResult, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      input.value = geoResult[0].formatted_address;
      setMapView(geoResult[0]);
    }
  }

  function queryAutocomplete(input) {
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode({
      "address": input,
      componentRestrictions: options.componentRestrictions
    }, autoCallback);
  }


  function onPlaceChanged() {
    var place = autocomplete.getPlace();
    if (place && place.geometry) {
      setMapView(place);
    } else {
      var input;
      if($(".pac-container .pac-item:first span:eq(3)").text() == "") {
        input = $(".pac-container .pac-item:first .pac-item-query").text();
      } else {
        input = $(".pac-container .pac-item:first .pac-item-query").text() + ", " + $(".pac-container .pac-item:first span:eq(3)").text();
      }
      if (input == '') {
        input = place.name;
      }

      queryAutocomplete(input);
      document.getElementById('placeAutocomplete').placeholder = '';
    }
  }

  function setMapView(geoResult) {
    if (geoResult && geoResult.geometry) {
      var geometry = geoResult.geometry;
      // TODO: following (commented) part should set appropriate zoom to
      // searched palce, unfortunatelly the zoom is too small.
      //
      // var viewport = geometry.viewport;
      // if (viewport) {
      //   console.log(viewport);
      //   console.log([[viewport.R.R, viewport.j.j], [viewport.R.j, viewport.j.R]]);
      //   map.fitBounds([[viewport.R.R, viewport.j.j], [viewport.R.j, viewport.j.R]], { maxZoom: 18, padding: [-150, -150] });
      // } else {
        map.panTo([geometry.location.lat(), geometry.location.lng()]);
        map.setZoom(18);
      //}
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
