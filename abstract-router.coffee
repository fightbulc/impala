define (require) ->
  _ = require 'underscore'
  Backbone = require 'backbone'
  Imp = require 'impala'
  Pubsub = require 'pubsub'

  ###############################################

  __private =
    moduleName: ->
      'abstract.router'

  ###############################################

  Backbone.Router.extend
    initialize: ->
      Imp.log [__private.moduleName(), 'init', Imp.getConfig()]

      #
      # Init history
      #
      Backbone.history.stop()
      Backbone.history.start root: Imp.getConfigByKey('url').public

      #
      # listen for redirect requests
      #
      Pubsub.subscribe 'router:redirect', @redirect

      #
      # listen for url updates
      #
      Pubsub.subscribe 'router:update', @updateUrl

    # -------------------------------------------

    redirect: (route) ->
      Imp.log [__private.moduleName(), 'redirect', route]
      Backbone.history.navigate "!/#{route}", trigger: true

    # -------------------------------------------

    updateUrl: (route) ->
      Imp.log [__private.moduleName(), 'updateUrl', route]
      Backbone.history.navigate "!/#{route}"

    # -------------------------------------------

    getCurrentRoute: ->
      Imp.log [__private.moduleName(), 'getCurrentRoute']
      window.location.hash.replace '#!/', ''

    # -------------------------------------------

    reloadPage: ->
      Imp.log [__private.moduleName(), 'reloadPage']
      route = @getCurrentRoute()
      Backbone.history.loadUrl "!/#{route}"
