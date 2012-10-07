define (require) ->
  _ = require 'underscore'

  #################################################

  class AbstractDto
    export: (vo) ->
      newData = {}

      _.each @getObjects(), (obj, key) ->
        value = vo[obj.vo]()

        if not value?
          value = obj.default

        else if _.isFunction obj.format
          value = obj.format value

        newData[key] = value

      newData

    # -------------------------------------------

    getObjects: ->
      {}

  #################################################

  AbstractDto