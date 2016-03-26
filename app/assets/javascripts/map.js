//resize map to "full window size" - from stackoverflow
var mapmargin = 50;
$('#map').css("height", ($(window).height() - mapmargin));
$(window).on("resize", resize);
resize();
function resize(){
  if($(window).width()>=980){
    $('#map').css("height", ($(window).height() - mapmargin));
    $('#map').css("margin-top",50);
  }else{
    $('#map').css("height", ($(window).height() - (mapmargin+12)));
    $('#map').css("margin-top",-21);
  }
}



var maxZoomEnabled = 15;
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
    osm: L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      name: "OpenStreetMap",
      type: "xyz",
      url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      layerOptions: {
        subdomains: ['a', 'b', 'c'],
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
          '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
        continuousWorld: true
      }
    }),
    map1_eu: L.tileLayer('http://beta.map1.eu/tiles/{z}/{x}/{y}.jpg', {
      name: "Map1.eu",
      type: "xyz",
      url: 'http://beta.map1.eu/tiles/{z}/{x}/{y}.jpg',
      layerOptions: {
        attribution: 'Tiles licence: ' +
          'map1.eu tiles by Pavel Klinger are licensed under a <a href="http://creativecommons.org/licenses/by-nc-nd/3.0/">Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License</a>.' +
          'Based on a work at <a href="http://map1.eu/">map1.eu</a>. ' +
          'Map data © OpenStreetMap contributors ',
        continuousWorld: true
      }
    }),
    hum_osm: L.tileLayer('http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
      name: "Humanitarian OSM",
      type: "xyz",
      url: 'http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
      layerOptions: {
        subdomains: ['a', 'b'],
        attribution: '© <a href="http://www.openstreetmap.org/copyright"></a>OpenStreetMap contributors</a>.' +
        'Tiles courtesy of <a href="http://hot.openstreetmap.org/">Humanitarian OpenStreetMap Team</a>',
        continuousWorld: true
      }
    }),
    osmCycle: L.tileLayer('http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png', {
      name: "OpenCycleMap",
      type: "xyz",
      url: 'http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png',
      layerOptions: {
        subdomains: ['a', 'b'],
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
          '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a> Tiles courtesy of <a href="www.thunderforest.com/">Andy Allan</a>',
        continuousWorld: true
      }
    })
};

var defaultStyle = {
  clickable: true,
  color: 'red',
  fillColor: '#FD8D3C',
  weight: 1.0,
  opacity: 1,
  fillOpacity: 0.5
};
var hoverStyle = {
  "fillOpacity": 0.5
};
var focusStyle = {
  fillColor: '#FF0003',
  color: '#000000',
  weight: 2,
  opacity: 1,
  fillOpacity: 1
};
var filteredStyle = {
  color: 'yellow',
  weight: 1,
  opacity: 1,
  fillOpacity: 0
};


// set window.params form query string
decodeQParams();

if (params.layers) {
  var activeLayers = params.layers.split(',').map(function(item) {
    return layers[item];
  });
}

var isFeatureFiltered = function isFeatureFiltered(feature) {
  if (!params['q[source_id_eq]']) {
    return false;
  }

  return !feature.properties.snippets.find(function(event) {
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
  style.fillColor = f.properties.legend_color || '#fff';
  if (params.shape_id && (f.id == params.shape_id)) {
    // highlight focus element
    return focusStyle;
  } else if (!params.shape_id && params['q[source_id_eq]']) {
    return style;
  } else if (!params.shape_id && params.from_date && params.to_date) {
    if (f.properties.snippets.find(function(event) {
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

var geojsonURL = '/tiles/{z}/{x}/{y}.json';
if (params['q[source_id_eq]']) {
  geojsonURL += '?q[source_id_eq]=' + params['q[source_id_eq]'] + '&q[source_type_eq]=' + params['q[source_type_eq]']
}
if (params['q[query]']) {
  geojsonURL += '?q[query]=' + params['q[query]'];
}
var geojsonTileLayer = new L.TileLayer.GeoJSON(geojsonURL, {
  clipTiles: true,
    unique: function (feature) {
      return feature.id;
    }
}, {
  style: styleFce,
  filter: function(feature, layer) {
    return !isFeatureFiltered(feature);
  },
  //pointToLayer: function(feature, latlng) {
  //  return isFeatureFiltered(feature) ? null : L.marker(latlng, {});
  //},
  onEachFeature: function (feature, layer) {
    var api_url = feature.properties && feature.properties.api_url;
    if (params['q[query]'] || params['q[source_id_eq]']) {
      api_url += '?event_ids=' + feature.properties.snippets.map(function(i) { return i.event_id }).join(',');
    }
    layer.on('click', function(e) {
      if (layer._popup != undefined) {
          layer.unbindPopup();
      }

      var popup = L.popup({maxWidth: 500}).setLatLng(e.latlng).setContent('<i class="fa fa-spinner fa-spin"></i> Načítám...').openOn($map);

      $.ajax({
        url: api_url,
        success: function (data) {
          popup.setContent(data);
          popup.update();
          $('[data-toggle="tooltip"]').tooltip();
        }
      });
      //popup.setContent('new data');
      //popup.update();
    });
    //layer.bindPopup(popupString, {
    //  maxHeight: 500,
    //  maxWidth: 500
    //});

    //if (!(layer instanceof L.Point)) {
    //    layer.on('mouseover', function () {
    //        layer.setStyle(hoverStyle);
    //    });
    //    layer.on('mouseout', function () {
    //        layer.setStyle(style);
    //    });
    //}
  }
});

var notificationsLayerGroup = L.layerGroup([]);

var overlays = {
  "Nalezené adresy": geojsonTileLayer,
  "Sledované oblasti": notificationsLayerGroup
};


var default_layers = function default_layers() {
  var res = [ layers.osm ];
  if (initialZoom >= maxZoomEnabled) {
    res.push(overlays.Events);
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
$map = map;
map.setView([49.802251, 15.6252330], 10);

var hash = L.hash(map);

L.control.scale().addTo(map);

var legend = L.control({position: 'bottomleft'});
legend.onAdd = function (map) {
  var div = L.DomUtil.create('div', 'info legend'),
  grades = [20, 100, 200, 400],
  labels = [];

  div.innerHTML += 'Počet událostí v dokumentu<br>';

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

var loading = L.Control.loading({separate: true}).addTo(map);

var zoomControll = function zoomControllFn(zoom) {
  if (zoom < maxZoomEnabled && map.hasLayer(geojsonTileLayer)) {
    map.removeLayer(geojsonTileLayer);
    $('#zoom-spinner').show();
  } else if (zoom >= maxZoomEnabled && map.hasLayer(geojsonTileLayer) == false) {
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
  console.log('redrawNotifications', notificationsStorage);
  if (notificationsStorage) {
    setNotifications(notificationsStorage);
  }
};
