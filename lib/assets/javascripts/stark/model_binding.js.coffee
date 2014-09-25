
"use strict"

window.Stark or= {}

class Stark.ModelBinding

  # Bind the given view to 'change' or 'destroy' events triggered on this model
  bind_view: (view) ->
    # @log "binding view", view.constructor.name, "to model", @.constructor.name

    # check if parent collection is already bound on this view
    if @collection? && _.include @collection.bound_views, view
      # @log "found our view already bound by our parent collection, bailing"
      return

    # check to see if any of our parent views have already been bound here
    #
    # if they have, we don't want to bind again because when the parent
    # redraws, we will get redrawn anyway.
    parent = view.parent
    while parent?
      if _.include @bound_views, parent
        # @log "found a parent view already bound, bailing"
        return
      if @collection? && _.include @collection.bound_views, parent
        # @log "found a parent view already bound by our parent collection, bailing"
        return
      parent = parent.parent

    # check if any of our children are bound here and remove them
    #
    # as above, if any child view previous bound to this model, we remove it
    # to avoid double rendering.
    @remove_children(@bound_views, view.views)

    @bound_views.push(view)
    model = @
    @onR view, "sync", (model, xhr, options) ->
      return if options.initial_load == true # true when loading during state transition
      @log "redraw handler fired (sync) due to model binding on: ", model
      @begin_closed_group "redrawing view: #{@.getClassName()}"
      @redraw()
      @end_group()

    # @onR view, "change", ->
    #   @log "redraw handler fired (change) due to model binding on: ", model
    #   @log "redrawing view: ", @
    #   @redraw()

    # @onR view, "destroy", ->
    #   @log "redraw handler fired (destroy) due to model binding on: ", model
    #   @log "redrawing view: ", @
    #   @redraw()

  unbind_view: (view) ->
    @bound_views = _.reject(@bound_views, (v) -> v == view)
    @unbind null, null, view

  # Search for any of views in targets
  remove_children: (targets, views) ->
    _.eachR @, views, (v) ->
      if _.include(targets, v)
        @log "found child view already bound; unbinding it"
        @unbind_view(v)
      @remove_children(targets, v.views)
