define (require) ->
  sf = require 'snakeface'

  ###############################################

  __private =
    moduleName: ->
      'lib.GA'

  ###############################################

  __public =
    track: (options) ->
      sf.log [__private.moduleName(), 'track', options.page]
      _gaq.push ['_trackPageview', "#!/#{options.page}"]