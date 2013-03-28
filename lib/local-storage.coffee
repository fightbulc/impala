define (require) ->
  _ = require 'underscore'
  Imp = require 'impala'
  AbstractManager = require 'abstract-manager'

  ###############################################

  class LocalStorageManager extends AbstractManager
    enabled = false

    # -------------------------------------------

    constructor: ->
      @enabled = true if window.localStorage

    # -------------------------------------------

    set: (key, value) ->
      return if not @enabled
      window.localStorage.setItem(key, value)

    # -------------------------------------------

    get: (key) ->
      return null if not @enabled
      window.localStorage.getItem(key)

    # -------------------------------------------

    remove: (key) ->
      return if not @enabled
      window.localStorage.removeItem(key)

  ###############################################

  new LocalStorageManager