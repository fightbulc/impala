define (require) ->
  class AbstractVo
    data: {}

    # -------------------------------------------

    setData: (data) ->
      @data data

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

    # -------------------------------------------

    export: (dto) ->
      dto = new dto()
      dto.export @

  #################################################

  AbstractVo