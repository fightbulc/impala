define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  Imp = require 'impala'
  Base = require 'base'
  Instance = require 'instance'
  AbstractManager = require 'abstract-manager'

  ###############################################

  __private =
    moduleName: ->
      'manager.StateModel'

  ###############################################

  class StateModelManager extends AbstractManager
    collectionInstanceName: null
    collectionInstance: null
    hookAttributeName: null
    relationsModelIds: []
    relationsModelCount: 0

    # -------------------------------------------

    _setCollectionInstanceName: (collectionInstanceName) ->
      @collectionInstanceName = collectionInstanceName
      @

    # -------------------------------------------

    _setHookAttributeName: (name) ->
      @hookAttributeName = name
      @

    # -------------------------------------------

    _setRelationsModelIds: (relationsModelIds) ->
      if relationsModelIds isnt false
        # cast to array
        relationsModelIds = [relationsModelIds] if not _.isArray relationsModelIds

        # set values
        @relationsModelIds = relationsModelIds
      @

    # -------------------------------------------

    _resetRelationsModelIds: ->
      @_setRelationsModelIds []

    # -------------------------------------------

    _getCollectionInstanceName: ->
      @collectionInstanceName

    # -------------------------------------------

    _getCollectionInstance: ->
      # create instance if not existing
      @collectionInstance = Instance.getCollection @_getCollectionInstanceName() if not @collectionInstance?

      # pass back
      @collectionInstance

    # -------------------------------------------

    _getHookAttributeName: ->
      @hookAttributeName

    # -------------------------------------------

    _getRelationsModelIds: ->
      @relationsModelIds

    # -------------------------------------------

    _addRelationsModelId: (modelId) ->
      # do nothing if id is already in relations
      return false if modelId in @_getRelationsModelIds()

      # add modelId
      @relationsModelIds.push modelId

      # refresh models
      @_refresh()

      return true

    # -------------------------------------------

    _removeRelationsModelId: (modelId) ->
      # do nothing if id is not in relations
      return false if modelId not in @_getRelationsModelIds()

      # renew models without the one we want to remove
      @_releaseOldModels _.without @relationsModelIds, modelId

      return true

    # -------------------------------------------

    _releaseOldModels: (newModelIdsMany) ->
      falseModelIds = _.difference @_getRelationsModelIds(), newModelIdsMany

      # if we have any modelIds
      if falseModelIds?
        # reset models to false
        for modelId in falseModelIds
          # if modelId is not longer part of relations objects
          model = @_getCollectionInstance().get modelId

          Imp.log ['RELEASE', @_getCollectionInstance(), modelId, model]

          # if model was pulled in to collection
          # set relations to false
          model.setByKey @_getHookAttributeName(), false if model?

      # set new model ids
      @_setRelationsModelIds newModelIdsMany

      # refresh models
      @_refresh()

    # -------------------------------------------

    _refresh: ->
      for modelId in @_getRelationsModelIds()
        # TODO: Implement getById in case model is not in collection
        model = @_getCollectionInstance().get modelId

        if model?
          # set relations = true
          # this should trigger the model's change event
          # and that should trigger a render-relation process
          # if the model is hooked to a view
          model.setByKey @_getHookAttributeName(), true

    # -------------------------------------------

    constructor: (collectionInstanceName, hookAttributeName, relationsModelIds, relationsModelCount) ->
      if relationsModelCount is undefined
        relationsModelCount = 0
        relationsModelCount = relationsModelIds.length if relationsModelIds?

      Imp.log [__private.moduleName(), '>>>', 'constructor', collectionInstanceName, hookAttributeName, relationsModelIds]

      # set initials
      @_setCollectionInstanceName collectionInstanceName
      @_setHookAttributeName hookAttributeName
      @_setRelationsModelIds relationsModelIds
      @relationsModelCount = relationsModelCount

      # refresh relation states when collection changed
      @_getCollectionInstance().on 'add', (model) => @_refresh()
      @_getCollectionInstance().on 'remove', (model) => @_refresh()

      # run initial
      @_refresh()

    # -------------------------------------------

    getCount: ->
      @relationsModelCount

    # -------------------------------------------

    getIds: ->
      @relationsModelIds

    # -------------------------------------------

    add: (modelId) ->
      Imp.log [__private.moduleName(), '>>>', @_getCollectionInstance(), 'add', modelId]

      # add state to model
      if @_addRelationsModelId modelId

        # increase the count
        @relationsModelCount += 1

        # tell the world
        @trigger "add", modelId

    # -------------------------------------------

    remove: (modelId) ->
      Imp.log [__private.moduleName(), '>>>', @_getCollectionInstance(), 'remove', modelId]

      # remove state from model
      if @_removeRelationsModelId modelId

        # reduce the count
        @relationsModelCount -= 1

        # tell the world
        @trigger "remove", modelId

    # -------------------------------------------

    reset: (newModelIdsMany) ->
      Imp.log [__private.moduleName(), '>>>', @_getCollectionInstance(), 'reset', newModelIdsMany]

      # sync before reset to release models we dont longer relate to
      # PS: we still love them, though ^^
      @_releaseOldModels newModelIdsMany

      # tell the world
      @trigger "reset", newModelIdsMany

    # -------------------------------------------

    empty: ->
      Imp.log [__private.moduleName(), '>>>', @_getCollectionInstance(), 'empty']

      # release all models
      @_releaseOldModels([])

      # tell the world
      @trigger "empty"
