define (require) ->
  imp = require 'impala'

  ###############################################

  __private =
    moduleName: ->
      'lib.GA'

  ###############################################

  __public =
    track: (options) ->
      imp.log [__private.moduleName(), 'track', options.page]
      _gaq.push ['_trackPageview', "#!/#{options.page}"]