
window.Stark or= {}
class Stark.ModelBinding

  bind_view: (view) ->

    # check to see if any of our parents have already bound here
    parent = view.parent
    while parent?
      if _.include @bound_views, parent
        @log "found a parent view already bound, bailing"
        return
      parent = parent.parent

    # check if any of our children are bound here and remove them
    @remove_children(@bound_views, view.views)

    @bound_views.push(view)
    model = @
    @bind "change", ->
      @log "redraw handler fired due to model binding on: ", model
      @log "redrawing view: ", @
      @redraw()
    , view

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
