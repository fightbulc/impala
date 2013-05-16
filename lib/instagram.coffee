define (require) ->
  imp = require 'impala'

  ###############################################

  __private =
    moduleName: ->
      'lib.Instagram'

  ###############################################

  __public =

    c_id: "be7ff209cdb34667af149a24c65d23d9"
    count: 0
    picArray: []
    numberOfPages: 5


    #-----------------------------------------------
    # Expects:
    #   longtitude  -> string
    #   latitude    -> string
    # Returns:
    #   calls member function getPics()
    #-----------------------------------------------

    getImagesByCoordinates: (options) ->
      imp.log [__private.moduleName(), 'getImagesByCoordinats', options]

      if options.lng? and options.lat?

        @count = 0
        @picArray = []

        # Empty array
        @picArray.length = 0

        options.distance ?= 50;#/in metres

        url = "https://api.instagram.com/v1/media/search?client_id="+@c_id+"&lat="+options.lat+"&lng="+options.lng+"&distance="+options.distance;

        @getPics url

      else
        imp.logError [__private.moduleName(), 'getImagesByCoordinates', 'missing lng or lat']


    #-----------------------------------------------
    # Expects:
    #   search term -> string
    # Returns:
    #   calls member function getPics()
    #-----------------------------------------------

    getImagesByTerm: (term) ->
      imp.log [__private.moduleName(), 'getImagesByTerm', term]

      if term

        @count = 0
        @picArray = []

        # Empty array
        @picArray.length = 0

        # create array of terms
        term = term.replace("berlin_","")
        terms = term.split("-")

        url = "https://api.instagram.com/v1/tags/"+terms[1]+"/media/recent?client_id="+@c_id
        console.log [url]
        @getPics url

      else
        imp.logError [__private.moduleName(), 'getImagesByTag', 'missing search term']


    #-----------------------------------------------
    # Expects:
    #   url -> string
    # Returns:
    #   calls member function paginate()
    #-----------------------------------------------

    getPics: (url) ->

      $.ajax
        type: "GET"
        dataType: "jsonp"
        url: url
        success: (response) =>
          if response.data?
            @paginate response
          if response.meta.error_message?
            imp.logError [__private.moduleName(), 'getImagesByTag Error', response.meta.error_message]


    #-----------------------------------------------
    # Expects:
    #   response -> object
    # Returns:
    #   publishes -> instagram:gotPics
    #   an array of instagram picture objects
    #-----------------------------------------------

    paginate: (response) ->

      @picArray = @picArray.concat response.data


      if response.pagination? and response.pagination.next_url? and @count < @numberOfPages
        @getPics response.pagination.next_url
        @count++

      else
        # pubsub.publish 'instagram:gotPics', @picArray
