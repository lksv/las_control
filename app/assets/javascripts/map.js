//resize map to "full window size" - from stackoverflow
var mapmargin = 50;
$('#map').css("height", ($(window).height() - mapmargin));
$(window).on("resize", resize);
resize();
function resize(){
  if($(window).width()>=980){
    $('#map').css("height", ($(window).height() - mapmargin));
  }else{
    $('#map').css("height", ($(window).height() - (mapmargin+12)));
  }
}



var maxZoomEnabled = 13;
var initialZoom = 13;

var mbAttr = 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
  '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
  'Imagery © <a href="http://mapbox.com">Mapbox</a>',
    mbUrl = 'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6IjZjNmRjNzk3ZmE2MTcwOTEwMGY0MzU3YjUzOWFmNWZhIn0.Y8bhBaUMqFiPrDRW9hieoQ';
/*
   var grayscale   = L.tileLayer(mbUrl, {id: 'mapbox.light', attribution: mbAttr}),
       streets  = L.tileLayer(mbUrl, {id: 'mapbox.streets',   attribution: mbAttr});

*/
var layers = {
    "Základní": L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      name: "OpenStreetMap",
      type: "xyz",
      url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
      continuousWorld: true
    }),
    "Satelitní": L.tileLayer('https://api.tiles.mapbox.com/v4/mapbox.streets-satellite/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibGtzdiIsImEiOiJjaW40OHNjbzcwMHNpdzVtMWRsMzE1aDI2In0.A1H4C1Zf8bBaXkWKPEL05Q', {
      attribution: '<a href="https://mapbox.com/about/maps/">MapBox</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      subdomains: 'abcd', maxZoom: 20, maxNativeZoom: 18,
    }),
    "Černobílá": L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
      subdomains: 'abcd',
      minZoom: 0,
      maxZoom: 20,
      maxNativeZoom: 18,
    })
    //map1_eu: L.tileLayer('http://beta.map1.eu/tiles/{z}/{x}/{y}.jpg', {
    //  name: "Map1.eu",
    //  type: "xyz",
    //  url: 'http://beta.map1.eu/tiles/{z}/{x}/{y}.jpg',
    //  maxZoom: 17,
    //  attribution: 'Tiles licence: ' +
    //    'map1.eu tiles by Pavel Klinger are licensed under a <a href="http://creativecommons.org/licenses/by-nc-nd/3.0/">Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License</a>.' +
    //    'Based on a work at <a href="http://map1.eu/">map1.eu</a>. ' +
    //    'Map data © OpenStreetMap contributors ',
    //  continuousWorld: true
    //}),
    //hum_osm: L.tileLayer('http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
    //  name: "Humanitarian OSM",
    //  type: "xyz",
    //  url: 'http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    //  subdomains: ['a', 'b'],
    //  attribution: '© <a href="http://www.openstreetmap.org/copyright"></a>OpenStreetMap contributors</a>.' +
    //  'Tiles courtesy of <a href="http://hot.openstreetmap.org/">Humanitarian OpenStreetMap Team</a>',
    //  continuousWorld: true
    //}),
    //osmCycle: L.tileLayer('http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png', {
    //  name: "OpenCycleMap",
    //  type: "xyz",
    //  url: 'http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png',
    //  subdomains: ['a', 'b'],
    //  attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
    //    '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a> Tiles courtesy of <a href="www.thunderforest.com/">Andy Allan</a>',
    //  continuousWorld: true
    //})
};

var defaultStyle = {
  clickable: true,
  color: 'red',
  fillColor: '#FD8D3C',
  weight: 1.0,
};
var hoverStyle = {
  "fillOpacity": 0.5
};
var focusStyle = {
  fillColor: '#FF0003',
  color: '#000000',
  weight: 2,
};
var filteredStyle = {
  fillColor: '#FFF',
  color: 'yellow',
  weight: 1,
  color: 'yellow'
};


// set window.params form query string
decodeQParams();

if (params.layers) {
  var activeLayers = params.layers.split(',').map(function(item) {
    return layers[item];
  });
}

var isFeatureFiltered = function isFeatureFiltered(feature) {
  var properties = feature.properties || feature.tags;

  //filter by date
  if (!params.shape_id &&
      !params['q[source_id_eq]'] &&
      params.from_date &&
      params.to_date) {
    return !(properties.snippets.find(function(event) {
      return (params.from_date < event.from_date) && (params.to_date > event.from_date);
    }));
  }

  if (!params['q[source_id_eq]']) {
    return false;
  }

  return !properties.snippets.find(function(event) {
    return (
      (event.source_id == params['q[source_id_eq]']) &&
      (event.source_type == params['q[source_type_eq]'])
    );
  });
};


window.getColor = function getColor(d) {
    return d > 400  ? '#ffffcc' :
           d > 200  ? '#a1dab4' :
           d > 100  ? '#41b6c4' :
           d > 20   ? '#2c7fb8' :
                      '#253494';
}

var styleFce = function styleFce(f) {
  var style = defaultStyle;
  style.fillColor = f.tags.legend_color || '#fff';
  if (style.fillColor == '#fff') {
    console.log(f.tags);
  }
  if (params.shape_id && (f.tags.id == params.shape_id)) {
    // highlight focus element
    return focusStyle;
  } else if (!params.shape_id && params['q[source_id_eq]']) {
    return style;
  } else if (!params.shape_id && params.from_date && params.to_date) {
    if (f.tags.snippets.find(function(event) {
      return (params.from_date < event.from_date) && (params.to_date > event.from_date);
    })) {
      return style;
    } else {
      return filteredStyle;
    }
    return style;
  } else {
    //no filter set at all
    return style;
  }
};

var geojsonURL = '/public/tiles/{z}/{x}/{y}.json';
if (params['private'] == 'true') {
  geojsonURL = geojsonURL.replace(/^\/public/, '');
}
if (params['q[source_id_eq]']) {
  geojsonURL += '?q[source_id_eq]=' + params['q[source_id_eq]'] + '&q[source_type_eq]=' + params['q[source_type_eq]']
}
if (params['q[query]']) {
  geojsonURL += '?q[query]=' + params['q[query]'];
}
var geojsonTileLayer = new L.geoJsonvtTiles(geojsonURL, {
  minZoom: maxZoomEnabled,
  debug: false,
  style: styleFce,
  filter: function(feature, layer) {
    return !isFeatureFiltered(feature);
  },
  featureClick: function(e, feature) {
    var map = this._map;

    var api_url = feature.properties && feature.properties.api_url;
    if (params['q[query]'] || params['q[source_id_eq]']) {
      api_url += '?event_ids=' + feature.properties.snippets.map(function(i) { return i.event_id }).join(',');
    }
    this._popup = L.popup({maxWidth: 500}).setLatLng(e.latlng).setContent('<i class="fa fa-spinner fa-spin"></i> Načítám...').openOn(map);

    var self = this;

    $.ajax({
      url: api_url,
      success: function (data) {
        self._popup.setContent(data);
        self._popup.update();
        $('[data-toggle="tooltip"]').tooltip();
      }
    });
  }
});

var notificationsLayerGroup = L.layerGroup([]);

var overlays = {
  "Nalezené dokumenty": geojsonTileLayer,
  "Moje oblasti": notificationsLayerGroup
};


var default_layers = function default_layers() {
  var res = [ layers['Základní'] ];
  if (initialZoom >= maxZoomEnabled) {
    res.push(geojsonTileLayer);
  }
  res.push(notificationsLayerGroup);
  return res;
};

// Create map
var map = new L.Map('map', {
  minZoom: 8,
  maxZoom: 18,
  zoom: initialZoom,
  layers: activeLayers || default_layers()
});
// just for debugging purposes
window.map = map;

map.attributionControl.setPrefix('By <a href="http://github.com/lksv">lksv</a>');

// get default map position
var leafletPosition = window.sessionStorage && window.sessionStorage.getItem('leafletPosition');
if (leafletPosition) {
  // when map was already opend we have stored last position
  var position = JSON.parse(leafletPosition);
  map.setView(position[0], position[1]);
} else {
  // set default position somewere middle CR,
  // leaflet.hash plugin rewrites default position if it is defined in anchor
  map.setView([50.08559, 14.41551], 17);
  if (location.hash.length <= 1) {
    // when no anchor is defined, try to guess position by geolocate API
    map.locate({setView : true});
  }
}

function updateLeafletPosition() {
  if (location.pathname.indexOf('/map') == 0) {
    var mapCenter = map.getCenter();
    var leafletPosition = JSON.stringify([[mapCenter.lat, mapCenter.lng], map.getZoom()]);
    sessionStorage.setItem('leafletPosition', leafletPosition);
  }
}
$(document).on("page:fetch", updateLeafletPosition);

var hash = L.hash(map);

L.control.scale().addTo(map);

var legend = L.control({position: 'bottomleft'});
legend.onAdd = function (map) {
  var div = L.DomUtil.create('div', 'info legend'),
  grades = [20, 100, 200, 400],
  labels = [];

  div.innerHTML += 'Počet adres v dokumentu (<a href="#" data-toggle="modal" data-target="#legendHelpModal">?</a>)<br>';

  // loop through our density intervals and generate a label with a colored square for each interval
  for (var i = -1; i < grades.length; i++) {
    div.innerHTML +=
      '<i style="background:' + getColor(grades[i] + 1) + '"></i> ' +
      (grades[i] || 1) + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+');
  }
  return div;
};
legend.addTo(map);

layers = L.control.layers(layers, overlays, { position: 'topleft' });
layers.addTo(map);

var loading = L.Control.loading({spinjs: true, separate: true, spin: {}}).addTo(map);

var zoomControll = function zoomControllFn(zoom) {
  if (zoom < maxZoomEnabled && map.hasLayer(geojsonTileLayer)) {
    map.removeLayer(geojsonTileLayer);
    $('#zoom-spinner').show();
  } else if (zoom >= maxZoomEnabled) {
    map.addLayer(geojsonTileLayer);
    $('#zoom-spinner').hide();
  }
};

map.on('zoomend', function () {
  zoomControll(map.getZoom());
});

zoomControll(map.getZoom());


var notificationsStorage = [];

window.setNotifications = function setNotifications(notifications) {
  notificationsStorage = notifications;

  notificationsLayerGroup.clearLayers();

  notifications.forEach(function(notification) {
    var marker = L.marker(
      [notification.lat, notification.lng],
      {
        draggable: true,
        zIndexOffset: 2000,
        title: 'Vaše sledovaná oblast: ' + notification.message
      }
    );
    marker.notificationId = notification.id;

    var showEditForm = function(ev) {
      var chagedPos = ev.target.getLatLng();
      var notification = notifications.find(function (n) {
        return n.id === ev.target.notificationId;
      });

      notification.lat = chagedPos.lat;
      notification.lng = chagedPos.lng;

      $('#tabble-nav a[href="#notifications"]').tab('show');

      var gpsLocation = '' + chagedPos.lat + ', ' + chagedPos.lng;

      if (
        $('form#edit_notification_' + ev.target.notificationId).length ||
        ($('form#new_notification').length && (notification.id === null))
      ) {
        // edit form for this notification is already rendered
        $('input#notification_gps_location').val(gpsLocation);
      } else {
        // load the form for this notification
        var form_url = 'notifications/' + ev.target.notificationId + '/edit?nocenter=true';
        $.getScript(form_url, function() {
          // update the position
          $('input#notification_gps_location').val(gpsLocation);
        });
      }
      setNotifications(notifications);
    };

    marker.on("dragend", showEditForm);
    marker.on("click", showEditForm);

    notificationsLayerGroup.addLayer(marker);

    notificationsLayerGroup.addLayer(
      L.circle(
        [notification.lat, notification.lng],
        notification.distance,
        {
          color: 'red',
          fillColor: '#f03',
          fillOpacity: 0.4,
          clickable: false
        }
      )
    );
  });
};

var redrawNotifications = function() {
  if (notificationsStorage) {
    setNotifications(notificationsStorage);
  }
};

// Activate proper tab
$(document).ready(
  function selectTab(){
    if (params.activeTab) {
      $('#tabble-nav a[href="#' + params.activeTab + '"]').tab('show');
    }
  }
);

$(document).ready(function () {
 $('#mapOptions .collapser').click(function(){
    var hidden = $('#mapOptions');
    if (hidden.hasClass('visible')){
      hidden.animate({"right":"-" + hidden.width() + "px"}, "slow").removeClass('visible');
    } else {
      hidden.animate({"right":"0px"}, "slow").addClass('visible');
    }
  });
});
