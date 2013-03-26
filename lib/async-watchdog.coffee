define (require) ->
  Imp = require('impala')
  AbstractManager = require('abstract-manager')

  ###############################################

  __private =
    moduleName: ->
      'manager.AsyncWatchdog'

  ###############################################

  class AsyncWatchdog extends AbstractManager
    constructor: (stages...) ->
      Imp.log [__private.moduleName(), 'constructor', stages]
      @stages = stages
      @completed = []

    # -------------------------------------------

    check: (stage) ->
      Imp.log [__private.moduleName(), 'check', stage]
      if stage in @stages and stage not in @completed
        @completed.push(stage)

        @trigger('complete') if @completed.length is @stages.length
