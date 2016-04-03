// Based on @Sumbera gist: https://gist.github.com/Sumbera/c67e5551b21c68dc8299

L.GeoJsonvtTiles =  L.TileLayer.Canvas.extend({
  options: {
    usedZoomLevel: 13,
    minZoom: 13,
    deubg: false,
    padding: 5,
    url: null,

    tileOptions: {
      maxZoom: 20, // max zoom to preserve detail on
      tolerance: 5, // simplification tolerance (higher means simpler)
      extent: 4096, // tile extent (both width and height)
      buffer: 64, // tile buffer on each side
      debug: 0, // logging level (0 to disable, 1 or 2)

      indexMaxZoom: 0, // max zoom in the initial tile index
      indexMaxPoints: 100000, // max number of points per tile in the index
    }
  },

    initialize: function (url, options) {
        this._url = url;
        this._tileIndexes = {};
        this._tilesToLoad = 0;
        //TODO: it's redundant. Could be removed after using gju instead of pip
        // used only of _getLatLngFeature
        this._tilesData = {};
        L.setOptions(this, options);

        var self = this;
        this.drawTile = function (tileCanvas, tilePoint, zoom) {
            this._draw(tileCanvas, tilePoint, zoom);
            if (self.options.debug) {
                self._drawDebugInfo(tileCanvas, tilePoint, zoom);
            }

        };
        return this;
    },

    onAdd: function (map) {
      map.on({
        'moveend': this._updateGeoJSON,
        'mousemove': this._moueMoveJSON,
        'click': this._clickGeoJSON
      }, this);
      L.TileLayer.prototype.onAdd.call(this, map);
      this._lastRedraw = new Date().getTime() - 1000;
      //this._updateGeoJSON();
    },

    onRemove: function (map) {
      map.off({
        'moveend': this._updateGeoJSON,
        'mousemove': this._moueMoveJSON,
        'click': this._clickGeoJSON
      }, this);
      L.TileLayer.prototype.onRemove.call(this, map);
    },

    addTo: function (map) {
        map.addLayer(this);
        return this;
    },

    _drawDebugInfo: function (tileCanvas, tilePoint, zoom) {
        var max = this.options.tileSize;
        var g = tileCanvas.getContext('2d');
        g.globalCompositeOperation = 'destination-over';
        g.strokeStyle = '#FFFFFF';
        g.fillStyle = '#FFFFFF';
        g.strokeRect(0, 0, max, max);
        g.font = "12px Arial";
        g.fillRect(0, 0, 5, 5);
        g.fillRect(0, max - 5, 5, 5);
        g.fillRect(max - 5, 0, 5, 5);
        g.fillRect(max - 5, max - 5, 5, 5);
        g.fillRect(max / 2 - 5, max / 2 - 5, 10, 10);
        g.strokeText(tilePoint.x + ' ' + tilePoint.y + ' ' + zoom, max / 2 - 30, max / 2 - 10);

    },

    /**
     * Transforms coordinates to tile space
     */
    tilePoint: function (map, coords,tilePoint, tileSize) {
        // start coords to tile 'space'
        var s = tilePoint.multiplyBy(tileSize);

        // actual coords to tile 'space'
        var p = map.project(new L.LatLng(coords[0], coords[1]));

        // point to draw
        var x = Math.round(p.x - s.x);
        var y = Math.round(p.y - s.y);
        return {
          x: x,
          y: y
        };
    },
    /**
     * Creates a query for the quadtree from bounds
     */
    _boundsToQuery: function (bounds) {
        if (bounds.getSouthWest() == undefined) { return { x: 0, y: 0, width: 0.1, height: 0.1 }; }  // for empty data sets
        return {
            x: bounds.getSouthWest().lng,
            y: bounds.getSouthWest().lat,
            width: bounds.getNorthEast().lng - bounds.getSouthWest().lng,
            height: bounds.getNorthEast().lat - bounds.getSouthWest().lat
        };
    },

    _draw: function (tileCanvas, tilePoint, zoom) {
        var tileSize = this.options.tileSize;
        var nwPoint = tilePoint.multiplyBy(tileSize);
        var sePoint = nwPoint.add(new L.Point(tileSize, tileSize));

        // padding to draw points that overlap with this tile but their center is in other tile
        var pad = new L.Point(this.options.padding, this.options.padding);

        nwPoint = nwPoint.subtract(pad);
        sePoint = sePoint.add(pad);

        var bounds = new L.LatLngBounds(this._map.unproject(sePoint), this._map.unproject(nwPoint));
        var zoomScale  = 1 / ((40075016.68 / tileSize) / Math.pow(2, zoom));
        // console.time('process');

        this.drawingOnCanvas.call(
          this,
          {
            canvas: tileCanvas,
            tilePoint: tilePoint,
            bounds: bounds,
            size: tileSize,
            zoomScale: zoomScale,
            zoom: zoom,
            options: this.options,
          }
        );
        // console.timeEnd('process');
    },



  ///////////////////////////////////////

  //for leaflet 1.x L.Util.throttle should be used
  deferedRedraw: function() {
    if (this._deferredRedraw) {
      clearTimeout(this._deferredRedraw);
      if (new Date().getTime() - this._lastRedraw > 300) {
        this.redraw();
        this._lastRedraw = new Date().getTime();
        return;
      }
    }

    var self = this;
    this._deferredRedraw = setTimeout(function() {
      self.redraw();
      self._lastRedraw = new Date().getTime();
    }, 200);

  },

  _moueMoveJSON: function(e) {
    var feature = this._getLatLngFeature(e.latlng);
    if (feature) {
      //document.getElementById('map').style.cursor = 'crosshair'
      $('.leaflet-container').css('cursor','pointer');
    } else {
      $('.leaflet-container').css('cursor','');
    }
  },

  _getLatLngFeature: function(latlng) {
    var x = latlng.lng;
    var y = latlng.lat;

    var map = this._map;
    var zoom = map.getZoom();
    var tilePoint = map.project(latlng, this.options.usedZoomLevel).divideBy(256).floor();
    var coords = new L.Point(tilePoint.x, tilePoint.y);
    coords.z = this.options.usedZoomLevel;
    var url = this.getTileUrl(coords);
    var t = this._tilesData[url];
    if (!t) {
      return;
    }
    var layerData = leafletPip.pointInLayer([x,y], t, true);
    return layerData[0] && layerData[0].feature;
  },

  //_getLatLngFeature: function(e) {
  //  var map = this._map;
  //  var zoom = map.getZoom();
  //  var lng = e.latlng.lng;
  //  var lat = e.latlng.lat;

  //  var features = [];
  //  var urls = this.getTileUrls(map.getBounds());
  //  urls.forEach(function(url) {
  //    var t = this._tileIndexes[url];
  //    if (t) {

  //      var tilePoint = map.project(e.latlng, zoom).divideBy(256).floor()
  //      tile = t.getTile(zoom, tilePoint.x, tilePoint.y);
  //      if (tile) {
  //        features = features.concat(tile.features);
  //      }
  //    }
  //  }, this);
  //  console.log(features);
  //  var feature = features.find(function(feature) {
  //    return (feature.type == 3) && gju.pointInPolygon({
  //      type: 'Point',
  //      coordinates: [lng, lat]
  //    }, feature)
  //  }, this);

  //  console.log('nasel jsem', feature);
  //},


  _clickGeoJSON: function(e) {
    var feature = this._getLatLngFeature(e.latlng);
    if (!feature) {
      return;
    }
    if (this.options.featureClick) {
      this.options.featureClick.call(this, e, feature);
    }
  },

  _updateGeoJSON: function() {
    var map = this._map;
    if (!map) { return; }
    if (map.getZoom() < this.options.minZoom) {
      return;
    }

    var bbox = map.getBounds();
    var urls = this.getTileUrls(bbox);
    console.log('Aktualni zoom: ', map.getZoom(), 'pocet tiles: ', urls.length);
    urls.forEach(function(url) {
      if (this._tilesData[url]) {
        //console.log('Data for ', url, ' already cached');
        return;
      }
      var self = this;
      this._tilesToLoad++;
      this.fire('loading');
      $.ajax({
        dataType: "json",
        url: url,
        success: function(data) {
          //console.log('loaded data for', url);

          //FIXME: get rid of Leaflet PIP plugin...
          self._tilesData[url] = L.geoJson(data, {
            onEachFeature: function(feature, layer) {
              layer.bindPopup(feature.properties.owner)
            },
            style: {color:'yellow'}
          });
          if (data && data.features && data.features.length) {
            self._tileIndexes[url] = geojsonvt(data, self.options.tileOptions);
            //console.log(self.options.updateInterval);
            self.deferedRedraw();
          } else {
            //console.warn('empty or invalid data', data);
          }
          self._tilesToLoad--;
          if (!self._tilesToLoad) {
            self.fire('load');
          }
        }
      }).error(function() {
        console.error('error loading url: ' + url);
        self._tilesToLoad--;
        if (!self._tilesToLoad) {
          self.fire('load');
        }
      });

    }, this);
  },

  ///////////////////////////////////////
  ///////////////////////////////////////
  drawingOnCanvas: function(params) {
    var bounds = params.bounds;
    params.tilePoint.z = params.zoom;

    var ctx = params.canvas.getContext('2d');
    ctx.globalCompositeOperation = 'source-over';


    //console.log('getting tile z' + params.tilePoint.z + '-' + params.tilePoint.x + '-' + params.tilePoint.y);

    var features = [];

    var urls = this.getTileUrls(bounds);
    urls.forEach(function(url) {
      //console.log('preparing drawing for url: ', url);
      var t = this._tileIndexes[url];
      if (t) {
        //console.log(params.tilePoint);
        var tile = t.getTile(params.tilePoint.z, params.tilePoint.x, params.tilePoint.y);
        if (tile) {
          //console.log('adding feautres for url: ', url, tile.features);
          features = features.concat(tile.features);
        }
      }
    }, this);

    ctx.clearRect(0, 0, params.canvas.width, params.canvas.height);

    if (params.zoom < this.minZoom) {
      return;
    }

    ctx.strokeStyle = 'red';
    ctx.lineWidth = 1;

    for (var i = 0; i < features.length; i++) {
      var feature = features[i],
        type = feature.type;

      if (this.options.filter && !this.options.filter(feature)) {
        continue;
      }

      if (this.options.style) {
        var style = this.options.style(feature);
        ctx.fillStyle = style.fillColor;
        ctx.lineWidth = style.weight;
        ctx.strokeStyle = style.color;
      } else {
        ctx.fillStyle = 'rgba(0,0,255,0.55)';
        ctx.lineWidth = 1;
        ctx.strokeStyle = 'black';
        console.log('jsem zde');
      }
      ctx.beginPath();

      for (var j = 0; j < feature.geometry.length; j++) {
        var geom = feature.geometry[j];

        if (type === 1) {
          var ratio = 3;
          ctx.arc(geom[0] * ratio, geom[1] * ratio, 2, 0, 2 * Math.PI, false);
          continue;
        }

        for (var k = 0; k < geom.length; k++) {
          var p = geom[k];
          var extent = 4096;

          var x = p[0] / extent * 256;
          var y = p[1] / extent * 256;
          if (k) ctx.lineTo(x, y);
          else ctx.moveTo(x, y);
        }
      }

      if (type === 3 || type === 1) ctx.fill('evenodd');
      ctx.stroke();
    }

  },


  ///////////////////////////////////////
  // coppied from https://gist.github.com/mourner/8825883
  getTileUrls: function (bounds) {
    var min = this._map.project(bounds.getNorthWest(), this.options.usedZoomLevel).divideBy(256).floor(),
    max = this._map.project(bounds.getSouthEast(), this.options.usedZoomLevel).divideBy(256).floor(),
    urls = [];

    for (var i = min.x; i <= max.x; i++) {
      for (var j = min.y; j <= max.y; j++) {
        var coords = new L.Point(i, j);
        coords.z = this.options.usedZoomLevel;
        urls.push(this.getTileUrl(coords));
      }
    }

    return urls;
  },

  ///////////////////////////////////////
  // coppied (and slightly modified) from Leaflet TileLayer.js
  // see https://github.com/Leaflet/Leaflet/blob/9560b28515586aa238218f1b29c1b68d4e09505d/src/layer/tile/TileLayer.js

  // @section Extension methods
  // @uninheritable
  // Layers extending `TileLayer` might reimplement the following method.
  // @method getTileUrl(coords: Object): String
  // Called only internally, returns the URL for a tile given its coordinates.
  // Classes extending `TileLayer` can override this function to provide custom tile URL naming schemes.
  getTileUrl: function (coords) {
    var data = {
      r: L.Browser.retina ? '@2x' : '',
      s: this._getSubdomain(coords),
      x: coords.x,
      y: coords.y,
      z: coords.z
    };
    return L.Util.template(this._url, L.extend(data, this.options));
  },

  _getSubdomain: function (tilePoint) {
    var index = Math.abs(tilePoint.x + tilePoint.y) % this.options.subdomains.length;
    return this.options.subdomains[index];
  }
});

L.geoJsonvtTiles = function (url, options) {
    return new L.GeoJsonvtTiles(url, options);
};
