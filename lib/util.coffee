define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  sf = require 'snakeface'
  momentjs = require 'moment'

  __private =
    moduleName: ->
      'lib.Util'

  ###############################################

  __public =
    #
    # Preloads an image and populates it on event.onload
    #
    imageLoadAsync: (options) ->
      #
      #   options:
      #     src       - url of the image to load (optional if target is set and has load-async set)
      #     target    - target jQuery img element (optional if src is set)
      #     errorSrc  - url of image to be used on target in case loading fails (optional)
      #     onSuccess - callback to be called on successful load (optional)
      #     onError   - callback to be called in case loading fails (optional)
      #

      #
      # src not set? Don't panic, let's check if we can find load-async in target element!
      #
      if not options.src? and options.target
        options.src = options.target.data('load-async')
        #
        # Not? Ok, now we can panic!
        #
        sf.logError [__private.moduleName(), 'imageLoadAsync', options, 'options.src is a mandatory option for imageLoadAsync!'] if not options.src?

      image = new Image()

      image.onload = ->
        #
        # If target is set, then populate it and remove load-async data property
        #
        if options.target
          options.target.attr('src', image.src)
          options.target.removeData('load-async')

        #
        # If onSuccess is set, then do the callback
        #
        if typeof options.onSuccess is 'function'
          options.onSuccess(image.src)

      image.onerror = ->
        #
        # Fail! If errorSrc is set and we have a target, then populate it
        #
        if options.target and options.errorSrc
          options.target.attr('src', options.errorSrc)

        #
        # Fail! If onError is set, then do the callback
        #
        if typeof options.onError is 'function'
          options.onError(image.src)

      image.src = options.src

    # -------------------------------------------

    #
    # Automated lazy loading of images with data-load-async set inside a scrolling viewport DOM element
    #
    lazyLoadViewport: (viewportElm) ->

      #
      # Trigger on viewport being scrolled
      #
      viewportElm.scroll =>

        #
        # Read bounding box of the viewport
        #
        viewportOffset = viewportElm.offset().top
        viewportHeight = viewportElm.height()

        #
        # Find all images inside the viewport that can be loaded
        #
        $imgs = viewportElm.find('img[data-load-async]')

        for img in $imgs
          $img = $(img)

          #
          # Get the offset of any given image relative to the viewport
          #
          imageRelativeOffset = $img.offset().top - viewportOffset
          imageHeight = $img.height()

          #
          # We filter all unflagged images and look for images that are visible in the viewport
          #
          if not img._flaggedForLoading and (imageRelativeOffset + imageHeight) >= 0 and imageRelativeOffset <= viewportHeight

            #
            # Flag the image so it doesn't get loaded more than once (extra boolean on DOM element is not sexy but safe, won't cause memory leaks)
            #
            img._flaggedForLoading = true

            #
            # Let the loading magic happen!
            #
            @imageLoadAsync(target: $img)

      #
      # Self-trigger to load everything that already is rendered in viewport
      #
      viewportElm.scroll()

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


    # -------------------------------------------

    #
    # get date object for now
    #
    getNow: ->
      now = new Date(momentjs().format('YYYY-MM-DD') + 'T21:05:00') #Use this to fake now
      now = momentjs().local()
      now

    # -------------------------------------------

    #
    # get date object for start of day plus offset
    #
    getStartOfDay: ->
      now = momentjs().sod()
      now
