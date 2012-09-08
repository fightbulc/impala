define (require) ->
  $ = require 'jquery'
  sf = require 'snakeface'
  Engine = require 'vendor/hoganjs/hogan-2.0.0.amd'

  ###############################################

  __private =
    moduleName: ->
      'lib.Template'

    # -------------------------------------------

    # holds all compilated templates
    compilations: {}

    # -------------------------------------------

    # all templates
    templates: {}

    # -------------------------------------------

    # all partials
    partials: {}

  ###############################################

  __public =
    init: ->
      @initialTemplateFetch()
      @getPartials()

    # -------------------------------------------

    initialTemplateFetch: ->
      scriptElements = $('script[type="text/html"]')
      @addTemplate $(elm).attr('id').replace('template-', ''), $(elm).html() for elm in scriptElements

    # -------------------------------------------

    compile: (mustache) ->
      Engine.compile mustache

    # -------------------------------------------

    addTemplate: (tmplId, tmplCode) ->
      __private.templates[tmplId] = tmplCode
      __private.compilations[tmplId] = @compile(tmplCode)
      __private.partials[tmplId] = {}

    # -------------------------------------------

    addPartial: (parentTmplId, partialTmplId) ->
      partialTmplId = String(partialTmplId).replace /[\{>\}\s]/g, ''
      __private.partials[parentTmplId][partialTmplId] = __private.compilations[partialTmplId]

    # -------------------------------------------

    getTemplate: (tmplId) ->
      __private.templates[tmplId]

    # -------------------------------------------

    getPartials: ->
      for id, code of templates
        results = code.match /\{\{>\s{0,1}\w+\}\}/g
        @addPartial id, name for i, name of results

    # -------------------------------------------

    getCompiledTemplate: (tmplId) ->
      sf.log [__private.moduleName(), tmplId, 'template doesnt exist'], true if not (tmplId of __private.compilations)
      __private.compilations[tmplId]

    # -------------------------------------------

    render: (tmplId, data) ->
      tmplObject = @getCompiledTemplate(tmplId)
      tmplObject.render data, __private.partials[tmplId]

  ###############################################

  __public