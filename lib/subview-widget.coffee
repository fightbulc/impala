define (require) ->
  _ = require 'underscore'
  Imp = require 'impala'
  AbstractView = require 'abstractView'
  AbstractCollection = require 'abstractCollection'
  Pubsub = require 'pubsub'

  ###############################################

  class SubviewWidget extends AbstractView
    tagName: 'div'
    moduleName: 'SubviewWidget'
    parentCollection: null
    subCollection: null
    subviewIds: []
    subviewClass: null
    subviewClassParameters: {}
    callback: null

    # -------------------------------------------

    initialize: ->
      Imp.log [@moduleName, '>>>', 'init']
      _.bindAll @, '_renderAll'

    # -------------------------------------------

    _getCallback: ->
      @callback

    # -------------------------------------------

    setCallback: (callback) ->
      @callback = callback
      @

    # -------------------------------------------

    _getParentCollection: ->
      @parentCollection

    # -------------------------------------------

    setParentCollection: (collection) ->
      @parentCollection = collection
      @

    # -------------------------------------------

    _getSubCollection: ->
      if not @subCollection?
        # create empty collection
        @subCollection = new AbstractCollection()

        # listen for reset
        @subCollection.on 'reset', @_renderAll

      @subCollection

    # -------------------------------------------

    _getSubviewIds: ->
      @subviewIds

    # -------------------------------------------

    setSubviewIds: (ids = []) ->
      @subviewIds = ids
      @

    # -------------------------------------------

    _getSubviewClass: ->
      @subviewClass

    # -------------------------------------------

    setSubviewClass: (viewClass) ->
      @subviewClass = viewClass
      @

    # -------------------------------------------

    _getSubviewClassParameters: ->
      @subviewClassParameters

    # -------------------------------------------

    setSubviewClassParameters: (viewClassParameters) ->
      @subviewClassParameters = viewClassParameters
      @

    # -------------------------------------------

    _fetchModels: ->
      Imp.log [@moduleName, '>>>', '_fetchModels']
      @_getParentCollection().getByIdsMany @_getSubviewIds(), (models) => @_resetSubCollection models

    # -------------------------------------------

    _resetSubCollection: (models) ->
      Imp.log [@moduleName, '_resetSubCollection', models]
      @_getSubCollection().reset models

    # -------------------------------------------

    _renderAll: ->
      Imp.log [@moduleName, '>>>', 'renderAll']

      # empty container
      @$el.empty()

      # class parameters
      parameters = @_getSubviewClassParameters()

      @subCollection.each (model) =>
        # attach model to parameters
        parameters.model = model

        # create subviewClass instance
        (new (@_getSubviewClass()) parameters).render().$el.appendTo @$el

        # tell the app when we are done
        (@_getCallback()) @$el if @_getSubCollection().isLast model

    # -------------------------------------------

    render: ->
      Imp.log [@moduleName, '>>>', 'render']

      # fetch models from parentCollection
      @_fetchModels()

      # return this
      @

  ###############################################

  SubviewWidget