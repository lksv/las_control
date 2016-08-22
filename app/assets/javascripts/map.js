// resize map to "full window size" - from stackoverflow
var mapmargin = parseInt($('main').css('margin-top'), 10);
setTimeout(function(){
  $('#map').css("height", ($(window).height() - mapmargin));
});

$(window).on("resize", resize);
resize();
function resize(){
  if($(window).width()>=980){
    $('#map').css("height", ($(window).height() - mapmargin));
  }else{
    $('#map').css("height", ($(window).height() - (mapmargin+12)));
  }
}

var QueryFilter = function() {
  this._states = {};
  this.query = window.params['q[query]'];
  this.clear()
};

QueryFilter.prototype.setQuery = function(query) {
  this.query = query;
  window.params['q[query]'] = query;
  this.clear();
  geojsonTileLayer.deferedRedraw();
};

QueryFilter.prototype.clear = function() {
  this._document_ids = {};
  this._allData = []
  var self = this;
  this._ignoreAborted = true;
  Object.keys(this._states).forEach(function (url) {
    var xhr = self._states[url];
    if (xhr && xhr.readyState !== 4) {
      xhr.abort();
    }
  });
  this._ignoreAborted = false;
  this._states = {};
};

QueryFilter.prototype.loadUrl = function(params) {
  var url = params.id;

  if (params.filter || !this.query || !url) {
    return;
  }


  var filter_url = url.replace(/\.json$/, '/document_ids.json').replace(/^\/public/, '');
  filter_url += '?q[query]=' + this.query;

  var state = this._states[url];
  if (state) {
    return;
  }

  var self = this;

  geojsonTileLayer.fire('loading', {id: url, filter: true});
  this._states[url] = $.ajax({
    dataType: 'json',
    url: filter_url,
    success: this._ajax_loaded.bind(this, url)
  }).error(this._ajax_error.bind(this, url));
};

QueryFilter.prototype._ajax_loaded = function(url, data) {
  geojsonTileLayer.fire('load', { id: url, filter: true });
  this._allData = this._allData.concat(data);
  this._document_ids[url] = data;
  geojsonTileLayer.deferedRedraw();
};


QueryFilter.prototype._ajax_error = function(url, err) {
  geojsonTileLayer.fire('load', { id: url, filter: true });
  if (this._ignoreAborted) {
    return
  }
  alert('Došlo k chybě při načítání. Zobrazení filtru nemusí být přesné');
};

QueryFilter.prototype.isLoaded = function(url) {
  if (this._states[url] && this._states[url].readyState === 4) {
    return true;
  }

  if (this._states[url]) {
    return false;
  }

  this.loadUrl({ id: url});
};

QueryFilter.prototype.getUrlData = function(url) {
  return this._document_ids[url];
};

QueryFilter.prototype.getAllData = function() {
  return this._allData;
};

var mbAttr = 'Map layer data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
  '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
  'Imagery © <a href="http://mapbox.com">Mapbox</a>',
    mbUrl = 'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6IjZjNmRjNzk3ZmE2MTcwOTEwMGY0MzU3YjUzOWFmNWZhIn0.Y8bhBaUMqFiPrDRW9hieoQ';
/*
   var grayscale   = L.tileLayer(mbUrl, {id: 'mapbox.light', attribution: mbAttr}),
       streets  = L.tileLayer(mbUrl, {id: 'mapbox.streets',   attribution: mbAttr});

*/
var defaultAttribution = 'Mapový podklad &copy; <a href="http://openstreetmap.org" data-no-turbolink=true data-turbolinks=false>OpenStreetMap</a> contributors ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/" data-no-turbolink=true data-turbolinks=false>CC-BY-SA</a>';

// you can use https://leaflet-extras.github.io/leaflet-providers/preview/
// and http://mc.bbbike.org/mc/?num=2&mt0=mapnik&mt1=mapnik-bw
// for choose ideal map
var layers = {
    "Základní": L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      name: "OpenStreetMap",
      type: "xyz",
      url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
      attribution: defaultAttribution,
      continuousWorld: true
    }),
    "Satelitní": L.tileLayer('https://api.tiles.mapbox.com/v4/mapbox.streets-satellite/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibGtzdiIsImEiOiJjaW40OHNjbzcwMHNpdzVtMWRsMzE1aDI2In0.A1H4C1Zf8bBaXkWKPEL05Q', {
      attribution: '<a href="https://mapbox.com/about/maps/" data-no-turbolink=true data-turbolinks=false>MapBox</a> &mdash; Map layer data &copy; <a href="http://www.openstreetmap.org/copyright" data-no-turbolink=true data-turbolinks=false>OpenStreetMap</a>',
      subdomains: 'abcd', maxZoom: 20, maxNativeZoom: 18,
    }),
    "Černobílá": L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
      attribution: defaultAttribution,
      subdomains: 'abc',
      minZoom: 0,
      maxZoom: 20,
      maxNativeZoom: 18,
    })

    // "Černobílá": L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png', {
    //   attribution: '&copy; <a href="http://www.openstreetmap.org/copyright" data-no-turbolink=true data-turbolinks=false>OpenStreetMap</a> &copy; <a href="http://cartodb.com/attributions" data-no-turbolink=true data-turbolinks=false>CartoDB</a>',
    //   subdomains: 'abcd',
    //   minZoom: 0,
    //   maxZoom: 20,
    //   maxNativeZoom: 18,
    // })
    //
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

var maxZoomEnabled = params['q[query]'] ? 15 : 14;
var initialZoom = 15;



if (params.layers) {
  var activeLayers = params.layers.split(',').map(function(item) {
    return layers[item];
  });
}

var isFeatureFiltered = function isFeatureFiltered(feature, url) {
  var properties = feature.properties || feature.tags;

  if (params['q[query]']) {
    // When filtering by query but document_ids are not loaded yet
    // do not show any data
    if (!queryFilter.isLoaded(url)) {
      return true;
    }
    //hide feature if non of the snippets has the source
    var data = queryFilter.getUrlData(url);
    if (!properties.snippets.find(function(event) {
      return (
       data.indexOf(event.source_id) !== -1
      )
    })) {
      return true;
    }
  }

  //filter by date
  if (!params.shape_id &&
      !params['q[source_id_eq]'] &&
      params.from_date &&
      params.to_date) {
    return !(properties.snippets.find(function(event) {
      return (params.from_date < event.from_date) && (params.to_date > event.from_date);
    }));
  }

  // filter by local_administration_unit.id
  if (params['q[lau_id_eq]']) {
    var filter_lau_id = params['q[lau_id_eq]'];
    return !properties.snippets.find(function(event) {
      return (event.lau_id == filter_lau_id);
    });
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
    return d > 400  ? '#c7e9b4' :
           d > 200  ? '#7fcdbb' :
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
var geojsonTileLayer = new L.geoJsonvtTiles(geojsonURL, {
  minZoom: maxZoomEnabled,
  debug: false,
  style: styleFce,
  filter: function(feature, layer, url) {
    return !isFeatureFiltered(feature, url);
  },
  featureClick: function(e, features) {
    if (features.length === 0) {
      return;
    }
    var map = this._map;

    this._popup = L.popup({maxWidth: 500}).setLatLng(e.latlng).setContent('<i class="fa fa-spinner fa-spin"></i> Načítám...').openOn(map);

    var self = this;
    var contentData = [];
    var documentIds = queryFilter.getAllData();
    features.forEach(function (feature) {
      var apiUrl = feature.properties && feature.properties.api_url;
      if (apiUrl) {
        if (params['q[query]'] || params['q[source_id_eq]'] || params['q[lau_id_eq]']) {
          apiUrl += '?event_ids=' + feature.properties.snippets.filter(function(i) {
            if (params['q[query]']) {
              return (documentIds.indexOf(i.source_id) !== -1);
            } if (params['q[lau_id_eq]']) {
              return (params['q[lau_id_eq]'] == i.lau_id)
            }else {
              return true;
            }
          }).map(function(i) {
            return i.event_id
          }).join(',');
        }

        $.ajax({
          url: apiUrl,
          success: function (data) {
            contentData.push(data);
            self._popup.setContent(contentData.join('<hr>'));
            self._popup.update();
            $('[data-toggle="tooltip"]').tooltip();
          }
        });
      };
    });
  }
});

window.queryFilter = new QueryFilter();
geojsonTileLayer.on('loading', function(params) {
  queryFilter.loadUrl(params);
});



var notificationsLayerGroup = L.layerGroup([]);

var overlays = {
  "Nalezené dokumenty": geojsonTileLayer,
  "Moje oblasti": notificationsLayerGroup
};


var default_layers = function default_layers() {
  var res = [ layers['Černobílá'] ];
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

map.attributionControl.setPrefix('<a class="hidden-xs" href="/terms" data-no-turbolink=true data-turbolinks=false>Smluvní podmínky</a>');

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
    map.locate({setView : true})
      .on('locationfound', function(e){
        setTimeout(function() {
          if (map.getZoom() < maxZoomEnabled) {
            map.setView([e.latitude, e.longitude], maxZoomEnabled);
          }
        }, 500);
      });
  }
}

function updateLeafletPosition() {
  var mapCenter = map.getCenter();
  var leafletPosition = JSON.stringify([[mapCenter.lat, mapCenter.lng], map.getZoom()]);
  sessionStorage.setItem('leafletPosition', leafletPosition);
}
map.on('moveend', updateLeafletPosition);

var hash = L.hash(map);

L.control.scale().addTo(map);

var legend = L.control({position: 'bottomleft'});
legend.onAdd = function (map) {
  var div = L.DomUtil.create('div', 'info legend'),
  grades = [20, 100, 200, 400];

  // loop through our density intervals and generate a label with a colored square for each interval
  var legend = '';
  for (var i = -1; i < grades.length; i++) {
    legend +=
      '<i style="background:' + getColor(grades[i] + 1) + '; margin: 1px; font-weight: bold; text-align: center;">';
    if (i == -1) { legend += '+'; }
    if (i == grades.length - 1) { legend += '-'; }
    legend += '</i><br>';
  }
  div.innerHTML =
    '<div><div style="display: inline-block; vertical-align: middle; padding-right: 5px;">' +
    legend +
    '</div>' +
    '<div style="display: inline-block; vertical-align: middle; text-align: center;">' +
    'Relevance<br>dokumentu<br>' +
    '(<a href="#" data-toggle="modal" data-target="#legendHelpModal">více...</a>)' +
    '</div> </div>';
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
)

$(document).ready(function () {
  $('.new-notification-set-tab').on('click', function() {
    $('#tabble-nav a[href="#notifications"]').tab('show');
  });
});

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
