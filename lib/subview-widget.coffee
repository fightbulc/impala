define (require) ->
  _ = require 'underscore'
  Imp = require 'impala'
  AbstractView = require 'abstract-view'
  AbstractCollection = require 'abstract-collection'
  Pubsub = require 'pubsub'

  ###############################################

  class SubviewWidget extends AbstractView
    tagName: 'div'
    moduleName: 'SubviewWidget'
    parentCollection: null
    subCollection: null
    subviewIds: []
    subviewById: {}
    subviewClass: null
    subviewClassParameters: {}
    callback: null
    sortingOptions: {}

    # -------------------------------------------

    initialize: ->
      Imp.log [@moduleName, '>>>', 'init']

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
        @subCollection.on 'reset', => @_renderAll()

      @subCollection

    # -------------------------------------------

    _getSubviewIds: ->
      @subviewIds

    # -------------------------------------------

    setSubviewIds: (ids = []) ->
      @subviewIds = ids
      @

    # -------------------------------------------

    _getSortingOptions: ->
      @sortingOptions

    # -------------------------------------------

    setSortingOptions: (key, reverse = false) ->
      @sortingOptions =
        key: key
        reverse: reverse
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

      # sort models if demanded
      models = @subCollection.sortByKey @_getSortingOptions() if @_getSortingOptions()?

      @subviewById = {}

      # build views
      for model in models
        # attach model to parameters
        parameters.model = model

        # create subviewClass instance
        @subviewById[model.id] = view = new (@_getSubviewClass()) parameters
        view.render().$el.appendTo @$el

        # tell the app when we are done
        (@_getCallback()) @$el if @_getSubCollection().isLast model

    # -------------------------------------------

    remove: (id) ->
      collection = @_getSubCollection()
      model = collection.get(id)

      # no model no pain
      return if not model?

      # remove the view from DOM and hash
      if (view = @subviewById[id])?
        view.$el.remove()
        delete @subviewById[id]

      # remove the model from the collection
      collection.remove(model)

    # -------------------------------------------

    render: ->
      Imp.log [@moduleName, '>>>', 'render']

      # fetch models from parentCollection
      @_fetchModels()

      # return this
      @

  ###############################################

  SubviewWidget