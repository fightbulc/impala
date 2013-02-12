define (require) ->
  _ = require 'underscore'
  Backbone = require 'backbone'

  ###############################################

  Backbone.Collection.extend
    reverseSorting: false

    # -------------------------------------------

    isLast: (model) ->
      isLast = false
      isLast = true if _.isEqual @last(), model
      isLast

    # -------------------------------------------

    getRandom: ->
      _.shuffle(@models).pop()

    # -------------------------------------------

    addOrUpdate: (data, options) ->
      #
      # get the idAttribute property from collection's model class, assume 'id' otherwise!
      #
      idAttribute = 'id'
      idAttribute = @model.prototype.idAttribute if @model isnt undefined

      id = data[idAttribute]

      model = @get(id)

      if model?
        model.set(data, options)
      else
        @add(data, options)
        model = @get(id)

      model

    # -------------------------------------------

    smartReset: (data) ->
      idsToKeep = []

      #
      # iterate through data and add new models to the collection
      #
      for item in data
        idsToKeep.push(item.id)
        @add(item) if not @get(item.id)

      #
      # iterate through the collection and remove all models that are not wanted
      #
      @each (model) =>
        @remove(model) if model.getVo().getId() not in idsToKeep

    # -------------------------------------------

    sortBy: ->
      #
      # Override to provide a reverse sorting trigger
      #
      models = _.sortBy(@models, @comparator)
      models.reverse() if @reverseSorting
      models

    # -------------------------------------------

    next: (model) ->
      i = @indexOf(model)
      return false if undefined is i or i < 0 or i >= (@.length - 1)
      @at(i + 1)

    # -------------------------------------------

    prev: (model) ->
      i = @indexOf(model)
      return false if undefined is i or i <= 0
      @at(i - 1)