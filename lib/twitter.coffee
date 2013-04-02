define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  imp = require 'impala'
  Pubsub = require 'pubsub'

  #################################################

  __private =
    moduleName: ->
      'lib.Twitter'

  #################################################

  class twitter
    constructor: ->
      imp.log [__private.moduleName(), 'constructor']

      @loadSdk()

    # -------------------------------------------

    getTwitterConfig: ->
      imp.log [__private.moduleName(), 'getTwitterConfig']

      Imp.getConfigByKey('twitter')


    # -------------------------------------------

    loadSdk: ->
      imp.log [__private.moduleName(), 'loadSdk']

      url = "//platform.twitter.com/widgets.js"

      $.getScript url , (data, textStatus, jqxhr) =>
        imp.log [__private.moduleName(), 'loadSdk',textStatus]

        Pubsub.subscribe 'twitter:loadTwitterButtons', (response) =>
          @loadTwitterButtons()

    # -------------------------------------------

    loadTwitterButtons: ->
      imp.log [__private.moduleName(), 'loadTwitterButtons']

      twttr.widgets.load()

    # -------------------------------------------

    getTweetButton: (options) ->

      if not _.isUndefined(options.href)
        params = []

        # set defaults
        options.onComplete ?= (button) -> imp.log [__private.moduleName(), 'getTweetButton:onComplete', button]

        options.href       ?= "http://www.goanteup.com/!#/bet/{{betData.id}}"
        options.text      ?= "Check this out on beatguide"
        options.via       ?= "Beatguideme"
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
                      data-url="'+options.href+'"
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
        imp.logError [__private.moduleName(), 'getTweetButton', 'missing options.href']


    # -------------------------------------------


  new twitter