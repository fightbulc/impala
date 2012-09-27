define (require) ->
  _ = require 'underscore'
  imp = require 'impala'

  #################################################

  __private =
    moduleName: ->
      'lib.Instance'

    # -------------------------------------------

    instances: {}

    # -------------------------------------------

    _instances:
      collections: {}
      models: {}
      views: {}
      managers: {}
      routers: {}

    # -------------------------------------------

    init: ->
      @instances = @_instances

    # -------------------------------------------

    setInstance: (type, key, instance) ->
      @.instances[type][key] = instance
      instance

    # -------------------------------------------

    hasInstance: (type, key) ->
      _.isUndefined(@instances[type][key]) is false

    # -------------------------------------------

    getInstance: (type, key) ->
      @instances[type][key] if @hasInstance type, key

    # -------------------------------------------

    removeInstance: (type, key) ->
      if @hasInstance type, key
        @instances[type][key].deconstruct() if not _.isUndefined @instances[type][key].deconstruct

        # remove from DOM, undelegate events
        @instances[type][key].remove() if type is 'views'

        delete @instances[type][key]

  #################################################

  __public =
    getAllInstances: ->
      __private.instances

    # -------------------------------------------

    reset: ->
      # views are special due to their DOM and event appearance
      instance.remove() for key, instance of __private.instances.views

      # now just set back to default
      __private.init()

    # -------------------------------------------

    setView: (key, instance) ->
      __private.setInstance 'views', key, instance

    # -------------------------------------------

    hasView: (key) ->
      __private.hasInstance 'views', key

    # -------------------------------------------

    getView: (key) ->
      __private.getInstance 'views', key

    # -------------------------------------------

    removeView: (key) ->
      __private.removeInstance 'views', key

    # ===========================================

    setCollection: (key, instance) ->
      __private.setInstance 'collections', key, instance

    # -------------------------------------------

    hasCollection: (key) ->
      __private.hasInstance 'collections', key

    # -------------------------------------------

    getCollection: (key) ->
      __private.getInstance 'collections', key

    # -------------------------------------------

    removeCollection: (key) ->
      __private.removeInstance 'collections', key

    # ===========================================

    setModel: (key, instance) ->
      __private.setInstance 'models', key, instance

    # -------------------------------------------

    hasModel: (key) ->
      __private.hasInstance 'models', key

    # -------------------------------------------

    getModel: (key) ->
      __private.getInstance 'models', key

    # -------------------------------------------

    removeModel: (key) ->
      __private.removeInstance 'models', key

    # ===========================================

    setManager: (key, instance) ->
      __private.setInstance 'managers', key, instance

    # -------------------------------------------

    hasManager: (key) ->
      __private.hasInstance 'managers', key

    # -------------------------------------------

    getManager: (key) ->
      __private.getInstance 'managers', key

    # -------------------------------------------

    removeManager: (key) ->
      __private.removeInstance 'managers', key

  #################################################

  # init object
  __private.init()

  # return public api
  __public
