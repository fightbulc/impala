define (require) ->
  Backbone = require 'backbone'

  class AbstractManager
    on: Backbone.Events.on

    # -------------------------------------------

    off: Backbone.Events.off

    # -------------------------------------------

    trigger: Backbone.Events.trigger

    # -------------------------------------------

    once: Backbone.Events.once

    # -------------------------------------------

    listenTo: Backbone.Events.listenTo

    # -------------------------------------------

    stopListening: Backbone.Events.stopListening

  #################################################

  AbstractManager