define (require) ->
  _ = require 'underscore'
  Backbone = require 'backbone'
  imp = require 'impala'
  pubsub = require 'pubsub'

  ###############################################

  __private =
    moduleName: ->
      'abstract.router'

  ###############################################

  Backbone.Router.extend
    initialize: ->
      imp.log [__private.moduleName(), 'init', imp.getConfig()]

      #
      # Init history
      #
      Backbone.history.stop()
      Backbone.history.start root: imp.getConfigByKey('url').public

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
      imp.log [__private.moduleName(), 'redirect', route]
      Backbone.history.navigate "!/#{route}", trigger: true

    # -------------------------------------------

    updateUrl: (route) ->
      imp.log [__private.moduleName(), 'updateUrl', route]
      Backbone.history.navigate "!/#{route}"

    # -------------------------------------------

    getCurrentRoute: ->
      imp.log [__private.moduleName(), 'getCurrentRoute']
      Backbone.history.fragment.replace '!/', ''
