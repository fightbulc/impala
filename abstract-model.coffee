define (require) ->
  _ = require 'underscore'
  Backbone = require 'backbone'
  imp = require 'impala'
  pubsub = require 'pubsub'

  ###############################################

  Backbone.sync = (method, model, options) ->
    options.error = (response, errorThrown, options) ->
      pubsub.publish
        channel: 'model:error'
        data: [
          error: errorThrown
          response: response
          options: options
        ]

    imp.jsonRequest options

  ###############################################

  Backbone.Model.extend
    vo: null

    constantRequestParams: {}

    # -------------------------------------------

    setConstantRequestParams: (paramsObject) ->
      @constantRequestParams = paramsObject

    # -------------------------------------------

    getConstantRequestParams: ->
      @constantRequestParams

    # -------------------------------------------

    resetConstantRequestParams: ->
      @constantRequestParams = {}

    # -------------------------------------------

    setVo: (VoClass) ->
      @vo = new VoClass @

    # -------------------------------------------

    getVo: ->
      @vo

    # -------------------------------------------

    getData: ->
      @toJSON()

    # -------------------------------------------

    setByKey: (key, val) ->
      @set key, val

    # -------------------------------------------

    getByKey: (key) ->
      @get key

    # -------------------------------------------

    fetchData: (options) ->
      @fetch @_prepareRequestOptions options

    # -------------------------------------------

    request: (options) ->
      imp.jsonRequest @_prepareRequestOptions options

    # -------------------------------------------

    #
    # inject constant params from VO
    #
    _prepareRequestOptions: (options) ->
      constantParams = @getConstantRequestParams()

      if constantParams?

        options.params = {} if not options.params?

        for key, val of constantParams
          options.params[key] = val

      options
