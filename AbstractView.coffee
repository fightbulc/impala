define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  Backbone = require 'backbone'

  ###############################################

  class AbstractView extends Backbone.View
    events: (childEvents = {}) ->
      _.extend childEvents, {}

  ###############################################

  AbstractView