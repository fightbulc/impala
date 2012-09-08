define (require) ->
  _ = require 'underscore'
  Backbone = require 'backbone'
  sf = require 'snakeface'
  pubsub = require 'pubsub'

  ###############################################

  __private =
    moduleName: ->
      'abstract.router'

  ###############################################

  Backbone.Router.extend
    initialize: ->
      sf.log [__private.moduleName(), 'init', sf.getConfig()]

      #
      # Init history
      #
      Backbone.history.stop()
      Backbone.history.start root: sf.getConfigByKey('url').public

      #
      # listen for redirect requests
      #
      pubsub.subscribe 'router:redirect', @redirect

      #
      # listen for url updates
      #
      pubsub.subscribe 'router:update', @updateUrl

    # -------------------------------------------

    redirect: (route) ->
      sf.log [__private.moduleName(), 'redirect', route]
      Backbone.history.navigate "!/#{route}", trigger: true

    # -------------------------------------------

    updateUrl: (route) ->
      sf.log [__private.moduleName(), 'updateUrl', route]
      Backbone.history.navigate "!/#{route}"

    # -------------------------------------------

    getCurrentRoute: ->
      sf.log [__private.moduleName(), 'getCurrentRoute']
      Backbone.history.fragment.replace '!/', ''
