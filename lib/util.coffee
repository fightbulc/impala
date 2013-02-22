define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  imp = require 'impala'
  momentjs = require 'moment'

  __private =
    moduleName: ->
      'lib.Util'

  ###############################################

  __public =
    #
    # Preloads an image and populates it on event.onload
    #
    loadImageAsync: (options) ->
      #
      #   options:
      #     src       - url of the image to load (optional if target is set and has load-async set)
      #     target    - target jQuery img element (optional if src is set)
      #     errorSrc  - url of image to be used on target in case loading fails (optional)
      #     onSuccess - callback to be called on successful load (optional)
      #     onError   - callback to be called in case loading fails (optional)
      #

      #
      # create new image
      #
      image = new Image()

      image.onload = ->
        #
        # if target is set, then populate it and remove load-async data property
        #
        if options.target
          options.target.attr('src', image.src)
          options.target.removeData('load-async')

        #
        # if onSuccess is set, then do the callback
        #
        if typeof options.onSuccess is 'function'
          options.onSuccess(image.src)

      image.onerror = ->
        #
        # fail! if errorSrc is set and we have a target, then populate it
        #
        if options.target and options.errorSrc
          options.target.attr('src', options.errorSrc)

        #
        # fail! If onError is set, then do the callback
        #
        if typeof options.onError is 'function'
          options.onError(image.src)

      #
      # fetch image
      #
      image.src = options.src

    # -------------------------------------------

    #
    # Automated lazy loading of elements inside of the document element
    #
    # Options:
    #   selector: elements selector
    #   onSuccess: what should be done when elements come into view
    #
    loadLazyElements: (options) ->
      #
      # Trigger on viewport being scrolled
      #
      $(document).scroll =>
        #
        # Read current specifications
        #
        windowHeight = $(window).height()
        scrollTop = $(document).scrollTop()

        #
        # Find all images inside the given container that can be loaded
        #
        $foundElements = options.selector

        for elm in $foundElements
          #
          # jquery object
          #
          $elm = $(elm)

          #
          # Get elemts current top pos
          #
          elmRelativePositionTop = $elm.position().top - scrollTop

          #
          # We filter all unflagged elements and look
          # for only for those visible in the viewport
          #
          if not elm._flaggedForLoading and elmRelativePositionTop <= windowHeight
            #
            # Flag the element so it doesn't get loaded more than once
            # (extra boolean on DOM element is not sexy but safe, won't cause memory leaks)
            #
            elm._flaggedForLoading = true

            #
            # Let the loading magic happen!
            #
            options.onSuccess $elm

      #
      # Self-trigger to load everything that already is rendered in viewport
      #
      $(document).scroll()

    # -------------------------------------------

    #
    # shrinks an array by the given size / optional randomizes array first
    #
    arrayShrink: (array, size = 10, random = false) ->
      array = _.shuffle array if random
      _u(array).first(size)

    # -------------------------------------------

    #
    # The regular expression
    #
    getUrlRexExp: ->
      /(\b(https?|ftp|file):\/\/[\-A-Z0-9+&@#\/%?=~_|!:,.;]*[\-A-Z0-9+&@#\/%=~_|])/igm

    # -------------------------------------------

    #
    # get URLs from text
    #
    getUrlsFromText: (text) ->
      text.match @getUrlRexExp()
