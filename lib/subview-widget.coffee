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
    subviewReplacementById: {}
    subviewClass: null
    subviewClassParameters: {}
    callback: null
    sortingOptions: null

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

      # sort models if demanded
      if @_getSortingOptions()?
        models = @subCollection.sortByKey @_getSortingOptions()
      else
        models = @subCollection.models

      @subviewById = {}
      @subviewReplacementById = {}

      # build views
      for model in models
        @_renderOne(model).$el.appendTo @$el

        # tell the app when we are done
        (@_getCallback()) @$el if @_getSubCollection().isLast model

    # -------------------------------------------

    _renderOne: (model) ->
      # class parameters
      parameters = @_getSubviewClassParameters()

      # attach model to parameters
      parameters.model = model

      # create subviewClass instance
      @subviewById[model.id] = (new (@_getSubviewClass()) parameters).render()

    # -------------------------------------------

    renderMany: (ids) ->
      @_getParentCollection().getByIdsMany ids, (models) =>

        # build views
        for model in models
          @_renderOne(model).$el.appendTo @$el

        # tell the app when we are done
        @callback(@$el) if typeof @callback is 'function'

    # -------------------------------------------

    remove: (id, replacement) ->
      collection = @_getSubCollection()
      model = collection.get(id)

      # no model no pain
      return if not model?

      $replacement = $(replacement)

      # remove the view from DOM and hash
      if (view = @subviewById[id])?
        if replacement?
          # store replacement for further use
          @subviewReplacementById[id] = $replacement

          # remove the view from the DOM and put the replacement in
          view.$el.replaceWith($replacement)

          # remove the view from the hash
          delete @subviewById[id]

        else
          # remove the view from the DOM
          view.$el.remove()

          # remove the view from the hash
          delete @subviewById[id]

          # remove the model from the collection
          collection.remove(model)

    # -------------------------------------------

    undoRemove: (id) ->
      collection = @_getSubCollection()
      model = collection.get(id)

      # no model no pain
      return false if not model?

      if ($replacement = @subviewReplacementById[id])?
        # recreate the view
        view = @_renderOne(model)

        # remove the replacement and bring the view back
        $replacement.replaceWith(view.$el)

        # delete the replacement
        delete @subviewReplacementById[id]

        @callback(@$el) if typeof @callback is 'function'

        return view

    # -------------------------------------------

    render: ->
      Imp.log [@moduleName, '>>>', 'render']

      # fetch models from parentCollection
      @_fetchModels()

      # return this
      @

  ###############################################

  SubviewWidget