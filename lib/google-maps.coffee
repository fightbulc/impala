define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  imp = require 'impala'
  pubsub = require 'pubsub'
  template = require 'template'
  template.addTemplate 'InfoWindow', require 'text!app/tmpl/map/info-window.mustache'


  ###############################################

  __private =
    moduleName: ->
      'lib.GoogleMaps'

  ###############################################

  __public =
    init: ->
      imp.log [__private.moduleName(), 'init']
      @loadSDK()

    loadSDK: ->
      imp.log [__private.moduleName(), 'loadSDK']

      require ['async!http://maps.google.com/maps/api/js?sensor=false'], =>
        pubsub.publish 'googleMaps:ready'

    addMapToCanvas: (ele) ->
      imp.log [__private.moduleName(), 'addMapToCanvas', ele]

      #
      # Find canvas in DOM and make it a map.
      #
      map = new google.maps.Map( $(ele)[0])

      map


    # -------------------------------------------

    addOptionsToMap: (map, options) ->
      imp.log [__private.moduleName(), 'addOptionsToMap', map, options]

      mapOptions =
        center: new google.maps.LatLng( options.lat, options.lng )
        zoom: options.zoom
        mapTypeControlOptions:
          style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
          mapTypeIds: [google.maps.MapTypeId.ROADMAP, 'beatguideMap']
          position: google.maps.ControlPosition.TOP_RIGHT
        panControl: true
        panControlOptions:
          position: google.maps.ControlPosition.TOP_RIGHT
        zoomControl: true
        zoomControlOptions:
          style: google.maps.ZoomControlStyle.LARGE
          position: google.maps.ControlPosition.TOP_RIGHT
        scaleControl: true
        scaleControlOptions:
          position: google.maps.ControlPosition.BOTTOM_RIGHT
        streetViewControl: true
        streetViewControlOptions:
          position: google.maps.ControlPosition.TOP_RIGHT

      #
      # Set map options
      #
      map.setOptions(mapOptions)


      #
      # Create an info window to display the club details
      #
      @addInfoWindowToMap()

    # -------------------------------------------

    addCustomStyleToMap: (map, options)->
      imp.log [__private.moduleName(), 'addCustomStyleToMap', map, options]

      #
      # Create a new StyledMapType object, passing it the array of styles,
      # as well as the name to be displayed on the map type control.
      #
      customStyle = new google.maps.StyledMapType(options,{name: "Beatguide"})

      #
      # Associate the styled map with the MapTypeId and set it to display.
      #
      map.mapTypes.set('beatguideMap', customStyle)
      map.setMapTypeId('beatguideMap')

    # -------------------------------------------

    zoomMapTo: (map, level) ->
      imp.log [__private.moduleName(), 'zoomMapTo', level]
      map.setZoom level

    # -------------------------------------------

    recenterMap: (map, lat, lng)->
      map.panTo new google.maps.LatLng(lat, lng)

    # -------------------------------------------

    addOneMarkerToMap: (map,obj)->
      # imp.log [__private.moduleName(), 'addOneMarkerToMap', map, obj]

      #
      # Creating a marker and positioning it on the map
      #
      marker = new google.maps.Marker
        position: new google.maps.LatLng(obj.lat, obj.lng)
        title: obj.name
        clickable: true
        map: map

      marker

    # -------------------------------------------

    hideAllMarkers: (markers) ->
      imp.log [__private.moduleName(), 'hideAllMarkers', markers]
      @hideMarker(marker) for markerId,marker of markers

    # -------------------------------------------

    showAllMarkers: (markers) ->
      imp.log [__private.moduleName(), 'showAllMarkers', markers]
      @showMarker(marker) for markerId,marker of markers

    # -------------------------------------------

    hideMarker: (marker) ->
      # imp.log [__private.moduleName(), 'hideMarker', marker]
      marker.setVisible(false)

    # -------------------------------------------

    showMarker: (marker) ->
      # imp.log [__private.moduleName(), 'showMarker', marker]
      marker.setVisible(true)

    # -------------------------------------------

    addInfoWindowToMap: ->
      #
      # Create an info window to display the club details
      #
      @infoWindow = new google.maps.InfoWindow

    # -------------------------------------------

    addInfoWindowToMarker: (map, dto, marker)->
      # imp.log [__private.moduleName(), 'addInfoWindowToMap', map, dto, marker]

      google.maps.event.addListener marker, 'click', =>

        #
        # reopen the infoWindow with the right marker
        #
        @openInfoWindow(map, marker, dto)

    # -------------------------------------------

    openInfoWindow: (map, marker, dto) ->

      #
      # Set template date from DTO
      #
      tmplData =
        venue: dto

      #
      # Change the content
      #
      @infoWindow.setContent(template.render 'InfoWindow', tmplData)

      @infoWindow.open(map, marker)

    # -------------------------------------------

    closeInfoWindow: ->

      @infoWindow.close()
