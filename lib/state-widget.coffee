define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  Backbone = require 'backbone'
  imp = require 'impala'
  instance = require 'instance'

  ###############################################

  class StateWidget extends Backbone.View
    events:
      'click a.state-off, a.state-on': 'handleState'

    # -------------------------------------------

    initialize: ->
      error = false

      # check if we got what we need
      if not @el
        imp.logError ['StateWidget', 'Missing el']
        error = true

      if not @model
        imp.logError ['StateWidget', 'Missing model']
        error = true

      if not @options.stateField
        imp.logError ['StateWidget', 'Missing options.stateField']
        error = true

      if not @options.callbackStateOn
        imp.logError ['StateWidget', 'Missing callbackStateOn function']
        error = true

      if not @options.callbackStateOff
        imp.logError ['StateWidget', 'Missing callbackStateOff function']
        error = true

      # if all cool start the view
      if not error
        # watch our field
        @model.on "change:#{@options.stateField}", => @setCurrentState()

        # render da shit
        @render()

    # -------------------------------------------

    getStateOffHtml: ->
      'STATE OFF'

    # -------------------------------------------

    getStateOnHtml: ->
      'STATE ON'

    # -------------------------------------------

    getWidgetHtml: ->
      '
      <span class="state-widget">
        <a href="#" class="state-off">' + @getStateOffHtml() + '</a>
        <a href="#" class="state-on">' + @getStateOnHtml() + '</a>
      </span>
      '

    # -------------------------------------------

    showStateOff: ->
      @$el.find('.state-on').hide()
      @$el.find('.state-off').fadeIn(250)

    # -------------------------------------------

    showStateOn: ->
      @$el.find('.state-off').hide()
      @$el.find('.state-on').fadeIn(250)

    # -------------------------------------------

    isStateOn: ->
      typeof @model.attributes[@options.stateField] isnt 'undefined' and @model.attributes[@options.stateField] is true

    # -------------------------------------------

    render: ->
      # insert template
      @$el.html @getWidgetHtml()

      # render initial state
      @setCurrentState()

    # -------------------------------------------

    setCurrentState: ->
      # if current state is "on" render state
      return @showStateOn() if @isStateOn() is true

      # else, if we get here render "off" state
      @showStateOff()

    # -------------------------------------------

    handleState: (e) ->
      e.preventDefault()
      e.stopPropagation()

      # make sure that we have a user session
      if instance.getManager('user').hasSession() is false
        instance.getManager('user').requestUserLogin e
        return

      # state off
      return @setStateOff() if @isStateOn() is true

      # if we get here: state on
      @setStateOn() if @isStateOn() is false

    # -------------------------------------------

    setStateOff: ->
      # set state: off
      @showStateOff()

      # if callback fails, role back
      rolebackCallback = (response) => @showStateOn() if response is 0

      # callback
      @options.callbackStateOff @model, rolebackCallback

    # -------------------------------------------

    setStateOn: ->
      # set state: on
      @showStateOn()

      # if callback fails, role back
      rolebackCallback = (response) => @showStateOff() if response is 0

      # callback
      @options.callbackStateOn @model, rolebackCallback

  ###############################################

  StateWidget