define (require) ->
  class AbstractModelVo
    model: null

    # -------------------------------------------

    constructor: (model) ->
      @setModel model

    # -------------------------------------------

    setModel: (model) ->
      @model = model if model?

    # -------------------------------------------

    getData: ->
      @model.getData()

    # -------------------------------------------

    getByKey: (key) ->
      value = @model.get key
      value = null if not value?
      value

    # -------------------------------------------

    setByKey: (key, val) ->
      @model.set key, val

    # -------------------------------------------

    export: (dto) ->
      dto = new dto()
      dto.export @

  #################################################

  AbstractModelVo