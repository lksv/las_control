//resize map to "full windown size" - from stackoverflow
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
  color: "#00D",
  fillColor: '#FD8D3C',
  weight: 6.0,
  opacity: 0.3,
  fillOpacity: 0.2
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


var params = {};
window.location.href.replace(/#.*/, '').replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
  params[key] = value;
});
if (params.layers) {
  var activeLayers = params.layers.split(',').map(function(item) {
    return layers[item];
  });
}

var isFeatureFiltered = function isFeatureFiltered(feature) {
  if (!params.source_id) {
    return false;
  }

  return feature.properties.snippets.find(function(event) {
      return !(
        (event.source_id == params.source_id) &&
        (event.source_type == params.source_type)
      );
  });
};

var styleFce = function styleFce(f) {
  if (!params.shape_id) {
    defaultStyle
  } else if (f.id == params.shape_id) {
    // highlight focus element
    return focusStyle;
  } else {
    return filteredStyle;
  }
};

var geojsonURL = 'http://localhost:3000/tiles/{z}/{x}/{y}.json';
if (params.source_id) {
  geojsonURL += '&source_id=' + params.source_id + '&source_type=' + params.source_type
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
    var api_url = feature.properties.api_url;
    layer.on('click', function(e) {
      if (layer._popup != undefined) {
          layer.unbindPopup();
      }

      var popup = L.popup().setLatLng(e.latlng).setContent('<i class="fa fa-spinner fa-spin"></i> Loading...').openOn($map);

      $.ajax({
        url: api_url,
        success: function (data) {
          popup.setContent(data);
          popup.update();
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
var overlays = {
  "Events": geojsonTileLayer
};


var default_layers = function default_layers() {
  var res = [ layers.osm ];
  if (initialZoom >= maxZoomEnabled) {
    res.push(overlays.Events);
  }
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

new L.Control.MiniMap(
  L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      type: "xyz",
      zoom: 5,
      layerOptions: {
        subdomains: ['a', 'b', 'c']
      }
    })
).addTo(map);

L.control.scale().addTo(map);
L.control.layers(layers, overlays).addTo(map);


var zoomControll = function zoomControll(zoom) {
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
