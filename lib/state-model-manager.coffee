define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  Imp = require 'impala'
  Base = require 'base'
  Instance = require 'instance'
  Pubsub = require 'pubsub'

  ###############################################

  __private =
    moduleName: ->
      'manager.StateModel'

  ###############################################

  class StateModelManager
    collectionInstanceName: null
    collectionInstance: null
    hookAttributeName: null
    relationsModelIds: []

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
      # add modelId
      @relationsModelIds.push modelId

      # refresh models
      @_refresh()

    # -------------------------------------------

    _removeRelationsModelId: (modelId) ->
      # renew models without the one we want to remove
      @_releaseOldModels _.without @relationsModelIds, modelId

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

    constructor: (collectionInstanceName, hookAttributeName, relationsModelIds) ->
      Imp.log [__private.moduleName(), '>>>', 'constructor', collectionInstanceName, hookAttributeName, relationsModelIds]

      # set initials
      @_setCollectionInstanceName collectionInstanceName
      @_setHookAttributeName hookAttributeName
      @_setRelationsModelIds relationsModelIds

      # refresh relation states when collection changed
      @_getCollectionInstance().on 'add', (model) => @_refresh()
      @_getCollectionInstance().on 'remove', (model) => @_refresh()

      # run initial
      @_refresh()

    # -------------------------------------------

    add: (modelId) ->
      Imp.log [__private.moduleName(), '>>>', @_getCollectionInstance(), 'add', modelId]

      # add state to model
      @_addRelationsModelId modelId

      # tell the world
      Pubsub.publish "StateModelManager:#{@_getCollectionInstanceName()}:add", modelId

    # -------------------------------------------

    remove: (modelId) ->
      Imp.log [__private.moduleName(), '>>>', @_getCollectionInstance(), 'remove', modelId]

      # remove state from model
      @_removeRelationsModelId modelId

      # tell the world
      Pubsub.publish "StateModelManager:#{@_getCollectionInstanceName()}:remove", modelId

    # -------------------------------------------

    reset: (newModelIdsMany) ->
      Imp.log [__private.moduleName(), '>>>', @_getCollectionInstance(), 'reset', newModelIdsMany]

      # sync before reset to release models we dont longer relate to
      # PS: we still love them, though ^^
      @_releaseOldModels newModelIdsMany

      # tell the world
      Pubsub.publish "StateModelManager:#{@_getCollectionInstanceName()}:reset", newModelIdsMany

    # -------------------------------------------

    empty: ->
      Imp.log [__private.moduleName(), '>>>', @_getCollectionInstance(), 'empty']

      # release all models
      @_releaseOldModels([])

      # tell the world
      Pubsub.publish "StateModelManager:#{@_getCollectionInstanceName()}:empty"
