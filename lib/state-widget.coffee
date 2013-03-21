define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  Backbone = require 'backbone'
  Imp = require 'impala'
  Instance = require 'instance'

  ###############################################

  class StateWidget extends Backbone.View
    events:
      'click': 'handleState'

    # -------------------------------------------

    initialize: ->
      error = false

      # check if we got what we need
      if not @el
        Imp.logError ['StateWidget', 'Missing el']
        error = true

      if not @model
        Imp.logError ['StateWidget', 'Missing model']
        error = true

      if not @options.stateField
        Imp.logError ['StateWidget', 'Missing options.stateField']
        error = true

      if not @options.callbackStateOn
        Imp.logError ['StateWidget', 'Missing callbackStateOn function']
        error = true

      if not @options.callbackStateOff
        Imp.logError ['StateWidget', 'Missing callbackStateOff function']
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
      @$el.find('.state-off').show()

    # -------------------------------------------

    showStateOn: ->
      @$el.find('.state-off').hide()
      @$el.find('.state-on').show()

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
      Imp.log ['state-widget', 'handleState', e]

      e.preventDefault()
      e.stopPropagation()

      # make sure that we have a user session
      if Instance.getManager('user').hasSession() is false
        Instance.getManager('user').requestUserLogin e
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