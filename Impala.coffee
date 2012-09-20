define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  pubsub = require 'pubsub'

  ###############################################

  __private =
    extraParams: {}
    pageScrollPosition: {}
    currentPageId: null

    # -------------------------------------------

    moduleName: ->
      'impala'

    # -------------------------------------------

    isLoggingEnabled: ->
      true if _.isUndefined(console) is false and __public.getConfigByKey('logging') is true

  ###############################################

  __public =
    log: (args) ->
      if console?
        if __private.isLoggingEnabled() is true
          try
            date = new Date
            args.unshift("#{date.getHours()}:#{date.getMinutes()}:#{date.getSeconds()}")
          catch e
          console.log args

    # -------------------------------------------

    logError: (args) ->
      console.error args if __private.isLoggingEnabled() is true

    # -------------------------------------------

    getConfig: ->
      window._appConfig

    # -------------------------------------------

    getConfigByKey: (key) ->
      @getConfig()[key]

    # -------------------------------------------

    hideInitialLoadingContainer: ->
      $('#initialLoadingContainer').fadeOut 'fast', -> $('#receivedPayloadContainer').show()

    # -------------------------------------------

    addExtraParam: (key, value) ->
      __private.extraParams[key] = value

    # -------------------------------------------

    #
    # Creates a JSON RPC request
    #
    jsonRequest: (options) ->
      # set default id if necessary
      options.id ?= 1

      # set empty params if not defined
      options.params ?= {}

      # defined API required
      if not _.isUndefined(options.api)
        # prepare API url
        @getConfigByKey('url').api = $.trim(@getConfigByKey('url').api)

        # api root
        apiRoot = "#{@getConfigByKey('url').api}"
        apiRoot = "#{@getConfigByKey('url').api}/mock" if options.mock is true

        # determine domain by api
        options.domain = options.api.toLowerCase().split('.').shift()

        # build url
        options.url = apiRoot + '/' + options.domain + '/'

        # set success handler if missing
        if _.isUndefined(options.success)
          options.success = (data, status) => @log [options.api, 'jsonRequest', 'SUCCESSHANDLER', data, status]

        # set error handler if missing
        if _.isUndefined(options.error)
          options.error = (data, message, options) => @logError [options.api, 'jsonRequest', 'ERRORHANDLER', message, data, options]

        # attach sessionId if available
        options.params._sessionId = sessionId if (sessionId = @getConfig().sessionId)?

        # add extra params
        options.params[key] = value for key, value of __private.extraParams

        # build POST data structure
        data =
          id: String(options.id)
          method: String(options.api)
          params: [options.params]

        # call server
        $.ajax
          url: options.url
          type: 'POST'
          contentType: 'application/json'
          dataType: 'json'

          # RPC structure
          # data: '{"id": "' + options.id + '", "method": "' + options.api + '", "params": [' + JSON.stringify(options.params) + ']}'
          data: JSON.stringify(data)

          # milliseconds
          timeout: 20000

          # on success
          success: (data, status) =>
            if not _.isUndefined data.result

              if not _.isEmpty(data.result) and not _.isUndefined(options.success)
                options.success data.result, status
                pubsub.publish 'jsonRequest:success', data.result

              else
                options.error data, 'Either received empty result or missing success callback', options

            else
              options.error data, 'Request failed', options

          # on fail
          error: (jqXHR, response, errorThrown) =>
            try
              response = JSON.parse(jqXHR.responseText).result.error
            catch error
              response = null

            if not _.isUndefined options.error
              options.error response, errorThrown, options

            else
              @logError ["#{__private.moduleName()}.jsonRequest", response, errorThrown, options]

        # no API defined
      else
        @logError ["#{__private.moduleName()}.jsonRequest", "options.api is undefined", options]

  ###############################################

  __public