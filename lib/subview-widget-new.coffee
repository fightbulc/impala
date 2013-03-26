define (require) ->
  _ = require 'underscore'
  Imp = require 'impala'
  AbstractView = require 'abstract-view'
  AbstractCollection = require 'abstract-collection'
  Pubsub = require 'pubsub'

  ###############################################

  class SubviewWidget extends AbstractView

    render: (ids) ->
      ids = [ids] if not _.isArray(ids)

      #for id in ids
      #  model = @_collection.get

