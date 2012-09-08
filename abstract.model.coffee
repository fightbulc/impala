define (require) ->
  _ = require 'underscore'
  Backbone = require 'backbone'
  sf = require 'snakeface'
  pubsub = require 'pubsub'

  ###############################################

  Backbone.Model.prototype.sync = (method, model, options) ->
    options.error = (response, errorThrown, options) ->
      pubsub.publish
        channel: 'model:error'
        data: [
          error: errorThrown
          response: response
          options: options
        ]

    sf.jsonRequest(options)

  ###############################################

  Backbone.Model.extend
    setVo: (vo) ->
      @vo = new vo(@)

    # -------------------------------------------

    getVo: ->
      @vo

    # -------------------------------------------

    getData: ->
      @toJSON()

    # -------------------------------------------

    getByKey: (key) ->
      @get key

    # -------------------------------------------

    request: (options) ->
      @fetch options
