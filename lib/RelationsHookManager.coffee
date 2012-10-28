define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  imp = require 'impala'
  base = require 'base'
  instance = require 'instance'

  ###############################################

  __private =
    moduleName: ->
      'manager.RelationsHook'
      
  ###############################################

  class RelationsHookManager
    collectionInstance: null
    hookAttributeName: null
    relationsModelIds: []

    # -------------------------------------------

    _setCollectionInstance: (collectionInstanceName) ->
      @collectionInstance = instance.getCollection collectionInstanceName
      @

    # -------------------------------------------

    _setHookAttributeName: (name) ->
      @hookAttributeName = name
      @

    # -------------------------------------------

    _setRelationsModelIds: (relationsModelIds) ->
      @relationsModelIds = relationsModelIds
      @

    # -------------------------------------------

    _resetRelationsModelIds: ->
      @_setRelationsModelIds []

    # -------------------------------------------

    _getCollectionInstance: ->
      @collectionInstance

    # -------------------------------------------

    _getHookAttributeName: ->
      @hookAttributeName

    # -------------------------------------------

    _getRelationsModelIds: ->
      @relationsModelIds

    # -------------------------------------------

    _addRelationsModelId: (modelId) ->
      @relationsModelIds.push modelId
      @_refresh()

    # -------------------------------------------

    _removeRelationsModelId: (modelId) ->
      @_releaseOldModels _.without @relationsModelIds, modelId

    # -------------------------------------------

    _refresh: ->
      for modelId in @_getRelationsModelIds()
        # TODO: implement getById in case model is not in collection
        model = @_getCollectionInstance().get modelId

        if model?
          # set relations = true
          # this should trigger the model's change event
          # and that should trigger a render-arelation process
          # if the model is hooked to a view
          model.setByKey @_getHookAttributeName(), true

    # -------------------------------------------

    _releaseOldModels: (newModelIdsMany) ->
      falseModelIds = _.difference @_getRelationsModelIds(), newModelIdsMany

      # if we have any modelIds
      if falseModelIds?
        # reset models to false
        for modelId in falseModelIds
          # if modelId is not longer part of relations objects
          model = @_getCollectionInstance().get modelId

          imp.log ['RELEASE', @_getCollectionInstance(), modelId, model]

          # if model was pulled in to collection
          # set relations to false
          model.setByKey @_getHookAttributeName(), false if model?

      @_setRelationsModelIds newModelIdsMany

      @_refresh()

    # -------------------------------------------

    constructor: (collectionInstanceName, hookAttributeName, relationsModelIds) ->
      imp.log [__private.moduleName(), '>>>', 'constructor', collectionInstanceName, hookAttributeName, relationsModelIds]

      # set initials
      @_setCollectionInstance collectionInstanceName
      @_setHookAttributeName hookAttributeName
      @_setRelationsModelIds relationsModelIds

      # refresh relation states when collection changed
      @_getCollectionInstance().on 'add', (model) => @_refresh()
      @_getCollectionInstance().on 'remove', (model) => @_refresh()

      # run initial
      @_refresh()

    # -------------------------------------------

    add: (modelId) ->
      imp.log [__private.moduleName(), '>>>', 'add', modelId]
      @_addRelationsModelId modelId

    # -------------------------------------------

    remove: (modelId) ->
      imp.log [__private.moduleName(), '>>>', 'remove', modelId]
      @_removeRelationsModelId modelId

    # -------------------------------------------

    reset: (newModelIdsMany) ->
      imp.log [__private.moduleName(), '>>>', 'reset', newModelIdsMany]

      # sync before reset to release models we dont longer relation
      # PS: we still love them, though ^^
      @_releaseOldModels newModelIdsMany

    # -------------------------------------------

    empty: ->
      imp.log [__private.moduleName(), '>>>', 'empty']

      @_releaseOldModels([])