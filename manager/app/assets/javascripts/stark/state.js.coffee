
"use strict"

window.Stark or= {}

class Stark.State

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "state"

  # mixin events
  _.extend @.prototype, Backbone.Events.prototype

  # Unique name for state. Used to transition directly from one state to another
  name:   null

  # URL pattern for this state. Used to create Routes.
  #
  # pattern is of the format:
  #
  #   "/foo/:param/bar"
  #
  # where :param would get extracted as a value in the @params hash injected
  # into the created state. params are also passed into the Models during autoloading.
  url:    null

  # List of views used by this state
  views:  []

  # Hash of models required by this state and its views. Models will be autolaoded
  # when the state is created. Views will only be rendered once loads are complete.
  #
  # { key: ModelClass }
  #
  # Once loaded, keys will be available directly within the state and view, as well as
  # in templates.
  models: {}

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
        @[key] = new model(data)
        @log "will ajax load:", @[key]
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
