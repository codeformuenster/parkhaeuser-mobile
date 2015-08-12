(function() {
  var centerLayer, createFeatureForNearestAndUserLocation, featureLayer, findMeLayer, findNearest, findUser, highlightNearest, map, nearest, nearestLayer, parkhaueser, parkhaus_frei;

  parkhaueser = '';

  L.mapbox.accessToken = 'pk.eyJ1IjoiY29kZWZvcm11ZW5zdGVyIiwiYSI6IldYQkVOencifQ.siqN1k-DBUe2A7KkV1NHEA';

  parkhaus_frei = function(feature) {
    return feature.properties.free > 0;
  };

  nearest = function(targetPoint, features) {
    var dist, nearestPoint;
    nearestPoint = null;
    dist = Infinity;
    features.features.forEach(function(pt) {
      if (parkhaus_frei(pt)) {
        if (!nearestPoint) {
          nearestPoint = pt;
          dist = turf.distance(targetPoint, turf.pointOnSurface(pt), 'miles');
          return nearestPoint.properties.distance = dist;
        } else {
          dist = turf.distance(targetPoint, turf.pointOnSurface(pt), 'miles');
          if (dist < nearestPoint.properties.distance) {
            nearestPoint = pt;
            return nearestPoint.properties.distance = dist;
          }
        }
      }
    });
    delete nearestPoint.properties.distance;
    return nearestPoint;
  };

  highlightNearest = function(nearest) {
    var highlightColor;
    highlightColor = "#1AA3E5";
    return featureLayer.eachLayer(function(layer) {
      if (layer.feature === nearest) {
        if (layer instanceof L.Marker) {
          layer.setIcon(L.mapbox.marker.icon({
            'marker-color': highlightColor
          }));
        } else {
          layer.setStyle({
            color: highlightColor
          });
        }
      }
    });
  };

  createFeatureForNearestAndUserLocation = function(userLocation, nearest, layer) {
    layer.setGeoJSON({
      "type": "FeatureCollection",
      "features": [nearest, userLocation]
    });
    return nearestLayer;
  };

  centerLayer = function(layer) {
    return map.fitBounds(layer.getBounds());
  };

  findNearest = function(search, searchIn) {
    return nearest(search, searchIn);
  };

  findUser = function() {
    map.locate();
    map.on('locationfound', function(e) {
      var findMeGeoJSON;
      findMeGeoJSON = {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [e.latlng.lng, e.latlng.lat]
        },
        properties: {
          'title': 'Here I am!',
          'marker-color': '#ff8888',
          'marker-symbol': 'star'
        }
      };
      findMeLayer.setGeoJSON(findMeGeoJSON);
      nearest = findNearest(findMeGeoJSON, parkhaueser);
      highlightNearest(nearest);
      centerLayer(createFeatureForNearestAndUserLocation(findMeGeoJSON, nearest, nearestLayer));
    });
  };

  map = L.mapbox.map('map', 'codeformuenster.n5di3b77').setView([51.959, 7.626], 15);

  featureLayer = L.mapbox.featureLayer().loadURL('http://parkleit-api.codeformuenster.org').addTo(map).on('ready', function(e) {
    parkhaueser = this.getGeoJSON();
    return featureLayer.eachLayer(function(layer) {
      var html, statusColor;
      html = layer.feature.properties.name + "<br/><p>Freie Plätze: " + layer.feature.properties.free;
      layer.bindPopup(html);
      statusColor = '#E83838';
      if (parkhaus_frei(layer.feature)) {
        statusColor = '#6CBA5B';
      }
      if (layer instanceof L.Marker) {
        layer.setIcon(L.mapbox.marker.icon({
          'marker-color': statusColor
        }));
      } else {
        layer.setStyle({
          fillColor: statusColor
        });
      }
    });
  });

  findMeLayer = L.mapbox.featureLayer().addTo(map);

  nearestLayer = L.mapbox.featureLayer();

  if (!navigator.geolocation) {
    geolocate.innerHTML = 'Geolocation is not available';
  } else {
    findUser();
  }

}).call(this);
