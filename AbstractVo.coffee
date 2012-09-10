define (require) ->
  abstractModel = require 'abstractModel'

  ###############################################

  class abstractVo
    model = null

    # -------------------------------------------

    constructor: (model) ->
      @model = model if model?

    # -------------------------------------------

    setData: (data) ->
      @model = new abstractModel(data)

    # -------------------------------------------

    getData: ->
      @model.getData()

    # -------------------------------------------

    getByKey: (key) ->
      value = @model.get(key) if @model?
      value = '' if not value?
      value

    # -------------------------------------------

    setByKey: (key, val) ->
      set = {}
      set[key] = val
      @model.set(set)

    # -------------------------------------------

    export: (dto) ->
      dto = new dto()
      dto.export @

  #################################################

  abstractVo