define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  imp = require 'impala'
  pubsub = require 'pubsub'

  #################################################

  __private =
    moduleName: ->
      'lib.Facebook'

    # -------------------------------------------

    isConnected: false

    # -------------------------------------------

    getFacebookConfig: ->
      conf = imp.getConfigByKey('facebook')

      # force facebook to get data from server
      conf.forceRoundtrip = false if _.isUndefined(conf.forceRoundtrip)

      # facebook redirect login url
      conf.redirectAuthUrl = 'https://www.facebook.com/dialog/oauth?client_id={{appId}}&scope={{scope}}&redirect_uri={{callbackUrl}}&response_type=token' if _.isUndefined(conf.redirectAuthUrl)

      # login callback url
      conf.callbackUrl = '/auth/facebook/' if _.isUndefined(conf.callbackUrl)

      conf

  #################################################

  __public =
    init: ->
      # init when sdk was loaded
      window.fbAsyncInit = =>
        # init
        FB.init
          appId: __private.getFacebookConfig()['appId']
          status: true
          cookie: true
          oauth: true
          xfbml: true
          frictionlessRequests: true

        # bind event listeners
        @initEventListeners()

      # load facebook sdk
      @loadSdk(window.document)

      #
      # parse XFBML
      #
      pubsub.subscribe('facebook:parsexfbml', -> FB.XFBML.parse())

    # -------------------------------------------

    loadSdk: (d) ->
      imp.log [__private.moduleName(), 'loadSDK']

      # create fb-root container
      $('body').prepend($('<div/>').attr('id', 'fb-root'))

      # load SKD
      id = 'facebook-jssdk'
      return false if d.getElementById(id)
      js = d.createElement('script')
      js.id = id
      js.async = true
      js.src = "//connect.facebook.net/en_US/all.js"
      s = d.getElementsByTagName('head')[0].appendChild(js)

      # handle load error
      s.onerror = (data) ->
        pubsub.publish 'facebook:sdkLoadFail', data

    # -------------------------------------------

    initEventListeners: ->
      imp.log [__private.moduleName(), 'initEventListeners']

      initCallback = (response) =>
        imp.log [__private.moduleName(), 'event:getLoginStatus', response]

        #
        # Set connection state
        #
        pubsub.subscribe 'facebook:authHasSession', @setConnectionState
        pubsub.subscribe 'facebook:authNoSession', @setConnectionState

        #
        # Auth
        #

        # user gets auth prompt
        FB.Event.subscribe 'auth.prompt', (response) ->
          imp.log [__private.moduleName(), 'event:auth.prompt']
          pubsub.publish 'facebook:authPrompt', response

        # user session state changes
        FB.Event.subscribe 'auth.sessionChange', (response) =>
          imp.log [__private.moduleName(), 'event:auth.sessionChange']
          @handleSessionRequestResponse(response)

        # user session state changes
        FB.Event.subscribe 'auth.statusChange', (response) =>
          imp.log [__private.moduleName(), 'event:auth.statusChange']
          @handleSessionRequestResponse(response)

        #
        # Like
        #

        # user liked
        FB.Event.subscribe 'edge.create', (response) ->
          pubsub.publish 'facebook:createdLike', response

        # user unliked
        FB.Event.subscribe 'edge.remove', (response) ->
          pubsub.publish 'facebook:removedLike', response

        #
        # Comment
        #

        # user commented
        FB.Event.subscribe 'comment.create', (response) ->
          pubsub.publish 'facebook:createdComment', response

        # user removed comment
        FB.Event.subscribe 'comment.remove', (response) ->
          pubsub.publish 'facebook:removedComment', response

        #
        # Message
        #

        # message send
        FB.Event.subscribe 'message.send', (response) ->
          pubsub.publish 'facebook:sentMessage', response

        #
        # App requests
        #

        # listen for login via redirect
        pubsub.subscribe 'facebook:loginViaRedirect', @loginViaRedirect

        # listen for login via popup
        pubsub.subscribe 'facebook:loginViaPopup', @loginViaPopup

        # listen for logout
        pubsub.subscribe 'facebook:logout', @logout

        # At that point facebook loaded & requested the
        # current session. Lets role!

        pubsub.publish 'facebook:ready', true

        #
        # handle passed response
        #

        @handleSessionRequestResponse(response)

      #
      # Get current session state
      #

      FB.getLoginStatus initCallback, __private.getFacebookConfig('forceRoundtrip')

    # -------------------------------------------

    handleSessionRequestResponse: (response) ->
      imp.log [__private.moduleName(), 'handleSessionRequestResponse', response]

      switch response.status
        when 'connected'
          imp.log [__private.moduleName(), 'authHasSession']

          #
          # we got a session and our
          # app is authorized
          #
          pubsub.publish 'facebook:authHasSession', response

        when 'not_authorized'
          imp.log [__private.moduleName(), 'authNotAuthorized / authNoSession']

          #
          # we got a facebook session but our
          # app is not authorized
          #
          pubsub.publish 'facebook:authNoSession', response
          pubsub.publish 'facebook:authNotAuthorized', response

        else
          imp.log [__private.moduleName(), 'authNoSession']

          #
          # report that we dont have a session
          #
          pubsub.publish 'facebook:authNoSession', response

      #
      # report that we got connection state
      #
      pubsub.publish 'facebook:hasConnectionState', response

    # -------------------------------------------

    setConnectionState: (state) ->
      __private.isConnected = state

    # -------------------------------------------

    hasConnection: ->
      __private.isConnected

    # -------------------------------------------

    getLoginUrl: ->
      imp.log [__private.moduleName(), 'getLoginUrl']

      params =
        appId: __private.getFacebookConfig()['appId']
        scope: __private.getFacebookConfig()['permissions'].join(',')
        callbackUrl: encodeURIComponent [imp.getFacebookConfig()['permissions'].join(','), imp.getFacebookConfig()['callbackUrl']].join ''

      authUrl = getConf().authUrl
      authUrl = authUrl.replace("{{#{key}}}", val) for key,val of params
      authUrl

    # -------------------------------------------

    loginViaRedirect: ->
      imp.log [__private.moduleName(), 'loginViaRedirect']
      window.location.href = @getLoginUrl()

    # -------------------------------------------

    loginViaPopup: (callback) ->
      imp.log [__private.moduleName(), 'loginViaPopup']

      #
      # cancel handling
      #
      cancelHandle = (response) ->
        imp.log [__private.moduleName(), 'login has been canceled'] if response.authResponse is null

      #
      # authenticate via popup
      #
      FB.login cancelHandle, scope: __private.getFacebookConfig()['permissions'].join(',')

    # -------------------------------------------

    logout: (callback) ->
      imp.log [__private.moduleName(), 'logout']
      FB.logout (response) ->
        callback() if callback isnt undefined

  # -------------------------------------------

    getPermissions: (responseCallback) ->
      imp.log [__private.moduleName(), 'getPermissions']
      FB.api '/me/permissions', responseCallback

    # -------------------------------------------

    requestPermissions: (permissions, callback) ->
      imp.log [__private.moduleName(), 'requestPermissions', permissions]
      FB.login callback, scope: permissions.join ','

    # -------------------------------------------

    sendAppRequest: (options) ->
      imp.log [__private.moduleName(), 'sendAppRequest', options]

      requestOptions =
        method: 'apprequests'
        message: options.message or 'Invite'

      # limited to a range of people (max.50)
      requestOptions.to = options.fbUserIds if not _.isEmpty options.fbUserIds

      # set default callback if none passed
      if _.isUndefined options.callback
        options.callback = (response) ->
          imp.log [__private.moduleName(), 'sendAppRequest:callback', response]

      # send request
      FB.ui requestOptions, options.callback

    # -------------------------------------------

    deleteAppRequest: (options) ->
      imp.log [__private.moduleName(), 'deleteAppRequest', options]

      if not _.isUndefined(options.requestId) and not _.isUndefined(options.recipientFbUserId)
        # set default callback if none passed
        if _.isUndefined(options.callback)
          options.callback = (response) ->
            imp.log [__private.moduleName(), 'deleteAppRequest:callback', response]

        FB.api "#{options.requestId}_#{options.recipientFbUserId}", 'DELETE', options.callback
      else
        imp.logError [__private.moduleName(), 'deleteAppRequest', 'missing params: requestId and/or recipientFbUserId']

    # -------------------------------------------

    getAppRequestDialog: (options) ->
      imp.log [__private.moduleName(), 'getAppRequestDialog', options]
      options.fbUserIds = []
      @sendAppRequest options

    # -------------------------------------------

    getLikeButton: (options) ->
      imp.log [__private.moduleName(), 'getLikeButton', JSON.stringify(options)]

      if not _.isUndefined(options.href)
        params = []

        # set defaults
        options.onComplete ?= (button) -> imp.log [__private.moduleName(), 'getLikeButton:onComplete', button]
        options.layout ?= 'button_count'
        options.show_faces ?= false
        options.font ?= 'lucida grande'
        options.action ?= 'like'
        options.colorscheme ?= 'dark'
        options.send ?= false
        options.width ?= '50'

        fbButton = '<div class="fb-like"
                    data-href="'+options.href+'"
                    data-send="'+options.send+'"
                    data-layout="'+options.layout+'"
                    data-width="'+options.width+'"
                    data-show-faces="'+options.show_faces+'"
                    data-colorscheme="'+options.colorscheme+'""
                    data-font="'+options.font+'""
                    data-action="'+options.action+'">
                  </div>'

        # build url with params
        # params.push([key, val].join '=') for key,val of options
        # fbButton = '<fb:like ' + params.join(' ') + '></fb:like>'
        options.onComplete fbButton

      else
        imp.logError [__private.moduleName(), 'getLikeButton', 'missing options.href']

    # -------------------------------------------

    createStreamPost: (options) ->
      imp.log [__private.moduleName(), 'createStreamPost', options]

      params =
        link: options.link
        name: options.name

      params.picture if not _.isUndefined options.picture
      params.message if not _.isUndefined options.message
      params.caption if not _.isUndefined options.caption
      params.description if not _.isUndefined options.description

      FB.api '/me/feed', 'POST', params, (response) -> imp.log [__private.moduleName(), 'createStreamPost:callback', response]

    # -------------------------------------------

    deleteStreamPost: (postId) ->
      imp.log [__private.moduleName(), 'deleteStreamPost', postId]
      FB.api postId, 'DELETE', (response) -> imp.log [__private.moduleName(), 'deleteStreamPost:callback', response] if not _.isEmpty(postId)

    # -------------------------------------------

    getUserImage: (fbUserId, size = 'square', ssl = false) ->
      #
      # Set url by fbUserId and size
      #
      url = 'http://graph.facebook.com/' + fbUserId + '/picture?type=' + size

      #
      # In case we want SSL
      #
      url = (url + '&return_ssl_resources=1').replace('http://', 'https://') if ssl is true

      #
      # return url
      #
      url

    # -------------------------------------------

    getUserDetails: (fbUserId, callback) ->
      FB.api "/#{fbUserId}", callback

    # -------------------------------------------

    parseDOM: ->
      imp.log [__private.moduleName(), 'parseDOM']
      if not _.isUndefined window.FB
        window.FB.XFBML.parse()
      else
        setTimeout((=> @parseDOM()), 3000)


  ###############################################

  __public