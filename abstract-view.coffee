define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  Backbone = require 'backbone'
  Imp = require 'impala'

  ###############################################

  class AbstractView extends Backbone.View
    moduleName: 'AbstractView'

    # -------------------------------------------

    events: (childEvents = {}) ->
      _.extend childEvents, {}

    # -------------------------------------------

    _getSubViews: ->
      @subViews ?= {}

    # -------------------------------------------

    _getSubView: (name) ->
      subView = null
      subView = @_getSubViews()[name] if @_getSubViews()[name]?
      subView

    # -------------------------------------------

    _addSubView: (name, viewInstance) ->
      Imp.log [@moduleName, '_addSubView', name]
      @_getSubViews()[name] = viewInstance

    # -------------------------------------------

    _removeSubView: (name) ->
      subViewInstance = @_getSubView name

      # remove view and its subviews
      if subViewInstance?
        subViewInstance._removeSubViews()
        subViewInstance.remove()
        delete @_getSubViews()[name]

    # -------------------------------------------

    _removeSubViews: ->
      subViews = @_getSubViews()

      # remove existing subViews
      if not _.isEmpty subViews
        @_removeSubView name for name, instance of subViews

  ###############################################

  AbstractView