
"use strict"

window.Stark or= {}

class Stark.State

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "state"

  _.extend @.prototype, Backbone.Events.prototype

  # static attributes
  name:   null
  url:    null
  views:  []
  models: []
  events: {}

  constructor: ->
    # internal attributes
    @_views = []

  # transition TO the given state
  transition: (state_name, state_data) ->
    @app.transition(state_name, state_data)

  # Copy state_data into the local scope
  # Return an array of any missing models so they can be loaded
  load_data: (data) ->
    needed = []
    _.each @models, (model, key) ->
      if data[key]
        @[key] = data[key] # copy into current [state] scope
      else
        @log "will ajax load:", model
        @[key] = new model(data.params)
        needed.push @[key]
    , @

    return needed

  # this is called by Stark when this state becomes active (transitioning TO)
  # optional, if extra setup is needed
  activate: ->
    # NO-OP

  # this is called by Stark when this state becomes deactive (transitioning AWAY)
  # optional, if extra teardown is needed
  deactivate: ->
    # NO-OP

  # return the URL that represents this state (substituting any params in @url)
  create_url: ->
    @url

  dispose: (new_state) ->
    @log "disposing of current state", @
    _.each @_views, (v) ->
      if ! (_.any(new_state.views, (n)-> v instanceof n) && _.any(new_state.no_redraw, (n)-> v instanceof n))
        # only dispose of view IF NOT required by new state
        @log "disposing of", v
        v.dispose()
    , @

  bind_app_events: ->
    _.each @app_events, (cb, key) ->
      @app.subscribe(key, cb)
    , @
