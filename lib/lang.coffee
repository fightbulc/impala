require (define) ->
  Engine = require 'vendor/hoganjs/hogan-2.0.0.amd'

  #################################################

  __private =
    moduleName: ->
      'lib.Template'

    # -------------------------------------------

    translations: {}

  #################################################

  lang = (string, vars) ->
    string = translations[string] if translations[string]?
    Engine.compile(string).render(vars)

  #################################################

  lang.setTranslations = (translations) =>
    __private.translations = translations

  #################################################

  lang