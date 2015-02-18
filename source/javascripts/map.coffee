parkhaueser = ''
L.mapbox.accessToken = 'pk.eyJ1IjoiY29kZWZvcm11ZW5zdGVyIiwiYSI6IldYQkVOencifQ.siqN1k-DBUe2A7KkV1NHEA'

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
  turf.nearest(search, searchIn)

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

map = L.mapbox.map('map', 'examples.map-i86nkdio')
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
