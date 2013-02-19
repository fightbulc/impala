define (require) ->
  imp = require 'impala'

  ###############################################

  __private =
    moduleName: ->
      'lib.GA'

  ###############################################

  __public =
    track: (page) ->
      imp.log [__private.moduleName(), 'track', page]
      _gaq.push ['_trackPageview', "#!/#{page}"]