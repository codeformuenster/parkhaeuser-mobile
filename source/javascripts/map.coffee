parkhaueser = ''
L.mapbox.accessToken = 'pk.eyJ1IjoiY29kZWZvcm11ZW5zdGVyIiwiYSI6IldYQkVOencifQ.siqN1k-DBUe2A7KkV1NHEA'

parkhaus_frei = (feature) ->
  feature.properties.free > 0

nearest = (targetPoint, features) ->
  nearestPoint = null
  dist = Infinity
  features.features.forEach (pt) ->
    if parkhaus_frei(pt)
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
  highlightColor = "#1AA3E5"
  featureLayer.eachLayer (layer) ->
    if layer.feature == nearest
      if layer instanceof L.Marker
        layer.setIcon L.mapbox.marker.icon
          'marker-color': highlightColor
        return
      else
        layer.setStyle
          color: highlightColor
        return

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

map = L.mapbox.map('map', 'codeformuenster.n5di3b77')
    .setView([51.959,7.626], 15)
featureLayer = L.mapbox.featureLayer()
    .loadURL('http://parkleit-api.codeformuenster.org')
    .addTo(map)
    .on('ready', (e) ->
      parkhaueser = this.getGeoJSON()
      featureLayer.eachLayer (layer) ->
        html = "#{layer.feature.properties.name}<br/><p>Freie Plätze: #{layer.feature.properties.free}"
        layer.bindPopup(html)
        statusColor = '#E83838'
        if parkhaus_frei(layer.feature)
          statusColor = '#6CBA5B'
        if layer instanceof L.Marker
          layer.setIcon L.mapbox.marker.icon
            'marker-color': statusColor
        else
          layer.setStyle
            fillColor: statusColor
        return
    )

findMeLayer = L.mapbox.featureLayer().addTo(map)
nearestLayer = L.mapbox.featureLayer()


if !navigator.geolocation
  geolocate.innerHTML = 'Geolocation is not available'
else
  findUser()
