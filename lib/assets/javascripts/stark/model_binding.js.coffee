
"use strict"

window.Stark or= {}

class Stark.ModelBinding

  # Bind the given view to 'change' or 'destroy' events triggered on this model
  bind_view: (view) ->
    # @log "binding view", view.constructor.name, "to model", @.constructor.name


    # TODO as with the below parent/child view checks, we should do the same
    #      with collections and models. we will often have a case where a parent
    #      view binds to the collection and it's child view binds to a model
    #      contained in that collection.


    # check to see if any of our parents (views) have already been bound here
    #
    # if they have, we don't want to bind again because when the parent
    # redraws, we will get redrawn anyway.
    parent = view.parent
    while parent?
      if _.include @bound_views, parent
        # @log "found a parent view already bound, bailing"
        return
      parent = parent.parent

    # check if any of our children are bound here and remove them
    #
    # as above, if any child view previous bound to this model, we remove it
    # to avoid double rendering.
    @remove_children(@bound_views, view.views)

    @bound_views.push(view)
    model = @
    @onR view, "sync", ->
      @log "redraw handler fired (sync) due to model binding on: ", model
      @log "redrawing view: ", @
      @redraw()

    # @onR view, "change", ->
    #   @log "redraw handler fired (change) due to model binding on: ", model
    #   @log "redrawing view: ", @
    #   @redraw()

    @onR view, "destroy", ->
      @log "redraw handler fired (destroy) due to model binding on: ", model
      @log "redrawing view: ", @
      @redraw()

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
