define (require) ->
  class AbstractVo
    data: {}

    # -------------------------------------------

    constructor: (data) ->
      @setData(data) if typeof data is 'object' and data isnt null
      @initalize() if typeof @initalize is 'function'

    # -------------------------------------------

    setData: (data) ->
      @data = data
      @

    # -------------------------------------------

    getData: ->
      @data

    # -------------------------------------------

    getByKey: (key) ->
      value = @data[key]
      value = null if not value?
      value

    # -------------------------------------------

    setByKey: (key, val) ->
      @data[key] = val
      @

  #################################################

  AbstractVo