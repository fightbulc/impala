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
    # Automated lazy loading of images with data-load-async set inside document element
    #
    lazyLoadImages: ($imageContainer) ->

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
        $imgs = $imageContainer.find('img[data-load-async]')

        for img in $imgs

          #
          # image jquery object
          #
          $img = $(img)

          #
          # Get current top pos for image
          #
          imageRelativePositionTop = $img.position().top - scrollTop

          #
          # We filter all unflagged images and look for images that are visible in the viewport
          #
          if not img._flaggedForLoading and imageRelativePositionTop <= windowHeight

            #
            # Flag the image so it doesn't get loaded more than once (extra boolean on DOM element is not sexy but safe, won't cause memory leaks)
            #
            img._flaggedForLoading = true

            #
            # Let the loading magic happen!
            #
            @imageLoadAsync
              src: $img.data('load-async')
              target: $img

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
