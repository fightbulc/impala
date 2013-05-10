define (require) ->
  _ = require 'underscore'
  Backbone = require 'backbone'
  Imp = require 'impala'
  Pubsub = require 'pubsub'

  ###############################################

  __private =
    moduleName: ->
      'abstract.router'

  ###############################################

  Backbone.Router.extend
    initialize: ->
      Imp.log [__private.moduleName(), 'init', Imp.getConfig()]

      #
      # Hashbang compatibility
      #
      window.location.hash = "##{window.location.hash.slice(3)}" if window.location.hash.slice(0, 3) is "#!/"

      #
      # Init history
      #
      Backbone.history.stop()
      Backbone.history.start root: Imp.getConfigByKey('url').public, pushState: true

      $(document).on "click", "a[href^='/']", (e) =>
        href = $(e.currentTarget).attr('href')

        # chain 'or's for other black list routes
        passThrough = href.indexOf('/downloads/') >= 0

        # Allow shift+click for new tabs, etc.
        if not passThrough and not e.altKey and not e.ctrlKey and not e.metaKey and not e.shiftKey
          e.preventDefault()

          # Remove leading slashes and hash bangs (backward compatablility)
          url = href.replace(/^\//,'').replace('\#\!\/','')

          # Instruct Backbone to trigger routing events
          Backbone.history.navigate url, { trigger: true }

          return false

      #
      # listen for redirect requests
      #
      Pubsub.subscribe 'router:redirect', @redirect

      #
      # listen for replace requests
      #
      Pubsub.subscribe 'router:replace', (route) => @redirect(route, true)

      #
      # listen for url updates
      #
      Pubsub.subscribe 'router:update', @updateUrl

    # -------------------------------------------

    redirect: (route, replace = false) ->
      Imp.log [__private.moduleName(), 'redirect', route, replace]
      Backbone.history.navigate route, trigger: true, replace: replace

    # -------------------------------------------

    updateUrl: (route) ->
      Imp.log [__private.moduleName(), 'updateUrl', route]
      Backbone.history.navigate route

    # -------------------------------------------

    getCurrentRoute: ->
      Imp.log [__private.moduleName(), 'getCurrentRoute']
      path = window.location.path
      hashPath = window.location.hash.replace '#!/', ''

      return hashPath if path is '' and hashPath isnt ''
      return path

    # -------------------------------------------

    reloadPage: ->
      Imp.log [__private.moduleName(), 'reloadPage']
      route = @getCurrentRoute()
      Backbone.history.loadUrl route
