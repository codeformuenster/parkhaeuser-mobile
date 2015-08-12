(function() {
  var centerLayer, createFeatureForNearestAndUserLocation, featureLayer, findMeLayer, findNearest, findUser, highlightNearest, map, nearest, nearestLayer, parkhaueser;

  parkhaueser = '';

  L.mapbox.accessToken = 'pk.eyJ1IjoiY29kZWZvcm11ZW5zdGVyIiwiYSI6IldYQkVOencifQ.siqN1k-DBUe2A7KkV1NHEA';

  nearest = function(targetPoint, features) {
    var count, dist, nearestPoint;
    nearestPoint = null;
    count = 0;
    dist = Infinity;
    features.features.forEach(function(pt) {
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
    });
    delete nearestPoint.properties.distance;
    return nearestPoint;
  };

  highlightNearest = function(nearest) {
    nearest.properties['marker-color'] = '#f00';
    nearest.properties['fill'] = '#f00';
    return nearest.properties['stroke'] = '#f00';
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

  map = L.mapbox.map('map', 'codeformuenster.ino9j865').setView([51.959, 7.626], 15);

  featureLayer = L.mapbox.featureLayer().loadURL('http://parkleit-api.codeformuenster.org/').addTo(map).on('layeradd', function(e) {
    return parkhaueser = this.getGeoJSON();
  });

  findMeLayer = L.mapbox.featureLayer().addTo(map);

  nearestLayer = L.mapbox.featureLayer().addTo(map);

  if (!navigator.geolocation) {
    geolocate.innerHTML = 'Geolocation is not available';
  } else {
    findUser();
  }

}).call(this);
