define (require) ->
  _ = require 'underscore'
  Imp = require 'impala'
  AbstractView = require 'abstract-view'

  ###############################################

  class SubviewWidget extends AbstractView
    views: []
    viewById: {}
    replacementById: {}
    length: 0

    # -------------------------------------------

    initialize: ->
      if @options.observe

        @collection.on 'add', (model, collection) =>
          id = model.id
          index = collection.indexOf(model)
          @addAt(id, index)

        @collection.on 'remove', (model) =>
          id = model.id
          @remove(id)

        @collection.on 'reset', (collection) =>
          @reset(collection.models)

    # -------------------------------------------

    _createView: (id) ->
      # create the view
      view = new @options.subviewClass(model: @collection.get(id))

      # apply the view to the hash, still have to put it manually into the array
      @viewById[id] = view

      # render
      view.render(@options.viewOptions)

      # apply callback to the view if given
      @options.callback(view) if typeof @options.callback is 'function'

      # increase count
      @length += 1

      # return
      view

    # -------------------------------------------

    get: (id) ->
      @viewById[id]

    # -------------------------------------------

    indexOf: (id) ->
      view = @get(id)

      return -1 if view is undefined

      @views.indexOf(view)

    # -------------------------------------------

    add: (items) ->
      items = [items] if not _.isArray(items)

      for item in items
        # can accept models as well as ids, need to handle that!
        if item.id?
          id = item.id
        else
          id = item

        view = @_createView(id)

        # put the view in order into the array
        @views.push(view)

        # append the view to the container
        @$el.append(view.$el)

    # -------------------------------------------

    addAt: (id, index) ->
      view = @_createView(id)

      # put the view in the array at correct position
      @views.splice(index, 0, view)

      # if the new view is first then prepend it to container
      return @$el.prepend(view.$el) if index is 0

      # handle negative index
      index = @views.length+index if index < 0

      # otherwise find previous child and insert the view into DOM after it
      previous = @views[index-1]
      previous.$el.after(view.$el)

    # -------------------------------------------

    addAfter: (id, after) ->
      index = @indexOf(after)

      throw new Error("Unknown view model id: #{after}") if index < 0

      @addAt(id, index+1)

    # -------------------------------------------

    addFirst: (id) ->
      @addAt(id, 0)

    # -------------------------------------------

    remove: (id, replacement) ->
      index = @indexOf(id)
      view = @get(id)

      if replacement
        $replacement = $(replacement)

        # store replacement for further use
        @replacementById[id] = $replacement

        # remove the view from the DOM and put the replacement in
        view.$el.replaceWith($replacement)

      else
        # remove the view from the DOM
        view.$el.remove()

        # only remove view from the array if no replacement is given
        @views.splice(index, 1)

      delete @viewById[id]

      # update length
      @length -= 1

    # -------------------------------------------

    undoRemove: (id) ->
      return if not @replacementById[id]

      $replacement = @replacementById[id]

      # recreate the view
      view = @_createView(id)

      # remove the replacement and bring the view back
      $replacement.replaceWith(view.$el)

      # delete the replacement
      delete @replacementById[id]

      return view

    # -------------------------------------------

    reset: (items) ->
      # remove all views from the DOM
      view.$el.remove() for view in @views

      # reset the widget
      @views = []
      @viewById = {}
      @length = 0

      # add new items if provided
      @add(items) if items?
