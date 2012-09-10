define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  imp = require 'impala'
  pubsub = require 'pubsub'

  #################################################

  __private =
    moduleName: ->
      'lib.Twitter'

  #################################################

  class twitter
    constructor: ->
      @loadSdk()

    # -------------------------------------------

    loadSdk: ->
      imp.log [__private.moduleName(), 'loadSdk']

      script = window.document.createElement('script')
      script.id = "twitter-wjs"
      script.src = "#{window.location.protocol}//platform.twitter.com/widgets.js"
      $('body').append(script)

    # -------------------------------------------

    loadTwitterButtons: ->
      try
        twttr.widgets.load()
      catch error
        @loadSdk()
        setTimeout((=> @loadTwitterButtons()), 3000)

    # -------------------------------------------

    getTweetButton: (options) ->

      if not _.isUndefined(options.url)
        params = []

        # set defaults
        options.onComplete ?= (button) -> imp.log [__private.moduleName(), 'getTweetButton:onComplete', button]

        options.url       ?= "http://www.goanteup.com/!#/bet/{{betData.id}}"
        options.text      ?= "Check this out on beatguide"
        options.via       ?= "Beatguide"
        options.related   ?= ""               #Related accounts
        options.count     ?= "horizontal"     #Count box position
        options.lang      ?= "en"             #The language for the Tweet Button
        options.counturl  ?= ""               #URL to which your shared URL resolves
        options.hashtags  ?= "#Berlin"        #Comma separated hashtags appended to tweet text
        options.size      ?= ""               #The size of the rendered button

        imp.log [__private.moduleName(),"Tweet Button Options", options]

        # build url with params
        tweetButton = '<a href="https://twitter.com/share"
                      class="twitter-share-button"
                      data-url="'+options.url+'"
                      data-text="'+options.text+'"
                      data-via="'+options.via+'"
                      data-related="'+options.related+'"
                      data-count="'+options.count+'"
                      data-lang="'+options.lang+'"
                      data-counturl="'+options.counturl+'"
                      data-hashtags="'+options.hashtags+'"
                      data-size="'+options.size+'"
                      ></a>'

        options.onComplete tweetButton

      else
        imp.logError [__private.moduleName(), 'getTweetButton', 'missing options.URL']


    # -------------------------------------------


  new twitter