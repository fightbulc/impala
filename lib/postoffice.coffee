define (require) ->
  _ = require 'underscore'
  imp = require 'impala'

  ###############################################

  __private =
    moduleName: ->
      'lib.Postoffice'

    # -------------------------------------------

    services: {}

    # -------------------------------------------

    timers: {}

    # -------------------------------------------

    defaultOptions:
      intervalMs: 5000
      params: {}
      posts: []
      handlers: {}
      handlerOrder: []

    # -------------------------------------------

    options: {}

  ###############################################

  __public =
    register: (options) ->
      #
      # Set new service
      #
      __private.services[options.api] = _.clone __private.defaultOptions

      #
      # set custom options
      #
      __private.services[options.api].params = options.params if options.params?
      __private.services[options.api].intervalMs = options.intervalMs if options.intervalMs?

      imp.log [__private.moduleName(), options.api, __private.services[options.api].intervalMs]

    # -------------------------------------------

    setParams: (api, params) ->
      __private.services[api].params or __private.services[api].params = {}
      for key, value of params
        __private.services[api].params[key] = value

    # -------------------------------------------

    setPosts: (api, post) ->
      __private.services[api].posts = post if __private.services[api] isnt undefined

    # -------------------------------------------

    setHandler: (api, group, worker) ->
      __private.services[api].handlers[group] = worker
      __private.services[api].handlerOrder.push(group)

    # -------------------------------------------

    getApi: (api) ->
      __private.services[api].api

    # -------------------------------------------

    getParams: (api) ->
      __private.services[api].params

    # -------------------------------------------

    runHandler: (api, group, data) ->
      __private.services[api].handlers[group](data) if __private.services[api].handlers[group]?

    # -------------------------------------------

    processPosts: (api) ->
      # process cached posts
      for group in __private.services[api].handlerOrder
        data = __private.services[api].posts[group]
        @runHandler(api, group, data) if data?

      # reset posts
      @resetPosts(api)

      # run again in x ms
      __private.timers[api] = setTimeout (=> @run(api)), __private.services[api].intervalMs

    # -------------------------------------------

    run: (api) ->
      clearTimeout(__private.timers[api]) if __private.timers[api]?

      if __private.services[api]?
#        imp.log [__private.moduleName(), 'run', api, __private.services[api]]

        #
        # run initials first
        #
        if __private.services[api].posts.length > 0
          @processPosts(api)

        #
        # pull new posts
        #
        else
          if __private.services[api].intervalMs > 0
            imp.jsonRequest
              api: api
              params: __private.services[api].params
              success: (response, status) =>
                response = response.postoffice if response.postoffice?
                @setPosts api, response
                @processPosts api
              error: =>
                @processPosts api

    # -------------------------------------------

    resetPosts: (api) ->
      __private.services[api].posts = [] if __private.services[api]?

    # -------------------------------------------

    remove: (api) ->
      imp.log [__private.moduleName(), 'remove', api]
      clearTimeout(__private.timers[api]) if __private.timers[api]?
      delete __private.services[api] if __private.services[api]?


    # -------------------------------------------

    reset: ->
      imp.log [__private.moduleName(), 'reset']
      __private.services = {}