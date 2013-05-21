define (require) ->
  $ = require('jquery')
  _ = require('underscore')
  AbstractView = require('abstract-view')

  ###############################################

  class AbstractPageView extends AbstractView
    moduleName: 'AbstractPageView'

    # -------------------------------------------

    attributes:
      'class': 'page'