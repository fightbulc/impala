define (require) ->
  $ = require 'jquery'
  sf = require 'snakeface'
  $.i18n = require 'vendor/i18next/i18next-1.2.3'

  ###############################################

  $.i18n.init
    useLocalStorage: false
    resGetPath: '/assets/locale/__lng__/__ns__.json'
    lng: 'en'
    fallbackLng: 'en'

  ###############################################

  __public =
    setLng: (lang) ->
      sf.log [api.module, 'setLang', lang]
      $.i18n.setLng lang

    # -------------------------------------------

    # locale json
    # -------------------------
    # app:
    #   firstname: 'Foo'
    #   lastname: 'Bar'
    #   fullname: '__firstname__ __lastname__'
    #
    # get locale
    # -------------------------
    # 1. get('app.firstname')
    # 2. get('app.fullname', {firstname:'app.firstname', lastname:'app.lastname'})
    #
    # output
    # -------------------------
    # 1. Foo
    # 2. Foo Bar
    get: (key, vars = {}) ->
      sf.log [api.module, 'get', key, vars]

      try
      # try to translate vars
        vars[k] = $.t v for k,v of vars

        # translate the actual string
        $.t key, vars
      catch error
        sf.logError [api.module, 'key missing', key, error]

  ###############################################

  api =
    module: 'lib.Locale'
    __public: __public