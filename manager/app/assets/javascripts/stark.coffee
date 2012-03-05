
# stark.js = IRON.backbone.js

#= require "stark_router"

"use strict"

window.Stark or= {}

# -----------------------------------------------------------------------------
class Stark.App

  # attributes
  current_state: null
  states: {}

  # for collecting bootstrapped
  data: {}

  router: new Stark.Router

  constructor: ->
    # console.log "initializing router"
    @router.app = @
    @subscribe('app:route', @matchRoute)

  add_state: (state) ->
    # console.log "add_state"
    s = new state()
    @states[s.name] = state
    state.app = @
    @router.match(s.url, s.name)
    state

  # bound to app:route event
  matchRoute: (route, params) ->
    console.log ""
    console.log "matchRoute()", route.state_name
    console.log route, params
    @transition route.state_name, { params: params }

  transition: (state_name, state_data) ->
    console.log ""
    console.log "transition", state_name, state_data
    if @current_state instanceof @states[state_name]
      console.log "same state, canceling"
      return

    state_data or= @data
    @data = {} # clear any bootstrapped data

    state = new @states[state_name]()
    state.app = @
    state.bind_app_events()

    console.log "got state_data", state_data
    _.extend(state, state_data)

    # get data that's still needed
    needed = state.load_data()

    if needed? && needed.length > 0
      app = @
      Backbone.multi_fetch needed, (err, results) ->
        app.render_views(state)
    else
      @render_views(state)

  copy_data_from_state: (state, view) ->
    _.each _.keys(state.models), (key) ->
      view[key] = state[key]

  render_views: (state) ->
    console.log "render_views "

    if @current_state?
      @current_state.deactivate()
      @current_state.dispose()

    # TODO implement no_redraw
    # create views
    _.each state.views, (v) ->
      console.log "creating view #{state.name}::#{v.name}"
      view = new v()
      @copy_data_from_state state, view
      view.app = @
      view.state = state
      view.bind_app_events()
      view.render()
      state._views.push view
    , @ # context for _.each

    # TODO update URL from state
    if @current_state? && state.url?
      # there was a previous state, update browser url
      @router.changeURL state.create_url()

    state.activate()
    @current_state = state





  # method used by Server-side template to bootstrap any models
  # on the first hit
  #
  # @param [Object] data   Data to boostrap with, hash of models
  bootstrap: (data) ->
    data or= {}
    @data = data

  # helper for converting string to function
  locate_model_by_name: (model) ->
    if (!model.match(/(List|Collection)$/))
      s = model.split(".")
      mn = s.pop()
      base = s.join(".")
      fn = @find_fn("#{base}.#{mn}Collection") || @find_fn("#{base}.#{mn}List")

    else
      fn = @find_fn(model)

    return fn

  # helper for converting string to function
  find_fn: (fn, base) ->
    # console.log "find_fn ", fn, base
    base or= window

    # console.log fn, base
    if fn.indexOf(".") >= 0
      s = fn.split(".")
      fn = s.shift()
      return @find_fn(s.join("."), base[fn])

    if base[fn]? && _.isFunction(base[fn])
      return base[fn]

    return null


  # Setup pub/sub
  _.extend @.prototype, Backbone.Events

  # Create Publish/Subscribe aliases
  subscribe   : Backbone.Events.on
  unsubscribe : Backbone.Events.off
  publish     : Backbone.Events.trigger


# -----------------------------------------------------------------------------
class Stark.State
  _.extend @.prototype, Backbone.Events

  # attributes
  name:   null
  url:    null
  views:  []
  models: []
  events: {}

  # internal attributes
  _views: []

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

  dispose: ->
    console.log "disposing of current state", @
    _.each @_views, (v) ->
      v.$el.html("")
      v.undelegateEvents()

  bind_app_events: ->
    _.each @app_events, (cb, key) ->
      @app.subscribe(key, cb)
    , @


# -----------------------------------------------------------------------------
class Stark.View extends Backbone.View

  state: null
  template: null
  app_events: null

  initialize: ->
    _.bindAll @
    @_template = new Template(JST[@template])

  render: ->
    $(@el).html(@_template.render(@))
    @

  # proxy for Stark.state#transition
  transition: (state_name, state_data) ->
    @state.transition(state_name, state_data)

  bind_app_events: ->
    _.each @app_events, (cb, key) ->
      @app.subscribe(key, cb)
    , @
