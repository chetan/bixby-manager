
class Stark.State
  _.extend @.prototype, Backbone.Events

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

  # this is where model objects should be resolved by the state
  load_data: ->
    # NO-OP
    null

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
    console.log "disposing of current state", @
    _.each @_views, (v) ->
      if ! (_.any(new_state.views, (n)-> v instanceof n) && _.any(new_state.no_redraw, (n)-> v instanceof n))
        # only dispose of view IF NOT required by new state
        console.log "disposing of", v
        v.dispose()

  bind_app_events: ->
    _.each @app_events, (cb, key) ->
      @app.subscribe(key, cb)
    , @
