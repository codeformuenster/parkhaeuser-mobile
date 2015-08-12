parkhaueser = ''
L.mapbox.accessToken = 'pk.eyJ1IjoiY29kZWZvcm11ZW5zdGVyIiwiYSI6IldYQkVOencifQ.siqN1k-DBUe2A7KkV1NHEA'

nearest = (targetPoint, features) ->
  nearestPoint = null
  count = 0
  dist = Infinity
  features.features.forEach (pt) ->
    if !nearestPoint
      nearestPoint = pt
      dist = turf.distance(targetPoint, turf.pointOnSurface(pt), 'miles')
      nearestPoint.properties.distance = dist
    else
      dist = turf.distance(targetPoint, turf.pointOnSurface(pt), 'miles')
      if dist < nearestPoint.properties.distance
        nearestPoint = pt
        nearestPoint.properties.distance = dist
  delete nearestPoint.properties.distance
  return nearestPoint

highlightNearest = (nearest) ->
  nearest.properties['marker-color'] = '#f00'
  nearest.properties['fill'] = '#f00'
  nearest.properties['stroke'] = '#f00'

createFeatureForNearestAndUserLocation = (userLocation, nearest, layer) ->
  layer.setGeoJSON
    "type": "FeatureCollection"
    "features": [nearest, userLocation]
  nearestLayer

centerLayer = (layer) ->
  map.fitBounds(layer.getBounds())

findNearest = (search, searchIn) ->
  nearest(search, searchIn)

findUser = ->
  map.locate()
  map.on 'locationfound', (e) ->
    findMeGeoJSON =
      type: 'Feature'
      geometry:
        type: 'Point'
        coordinates: [
          e.latlng.lng
          e.latlng.lat
        ]
      properties:
        'title': 'Here I am!'
        'marker-color': '#ff8888'
        'marker-symbol': 'star'
    findMeLayer.setGeoJSON findMeGeoJSON
    nearest = findNearest(findMeGeoJSON,parkhaueser)
    highlightNearest(nearest)
    centerLayer(createFeatureForNearestAndUserLocation(findMeGeoJSON, nearest, nearestLayer))
    return
  return

map = L.mapbox.map('map', 'codeformuenster.ino9j865')
    .setView([51.959,7.626], 15)
featureLayer = L.mapbox.featureLayer()
    .loadURL('http://parkleit-api.codeformuenster.org/')
    .addTo(map)
    .on('layeradd', (e) ->
      parkhaueser = this.getGeoJSON()
    )

findMeLayer = L.mapbox.featureLayer().addTo(map)
nearestLayer = L.mapbox.featureLayer().addTo(map)


if !navigator.geolocation
  geolocate.innerHTML = 'Geolocation is not available'
else
  findUser()
