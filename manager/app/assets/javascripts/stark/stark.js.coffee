
# stark.js = IRON.backbone.js

"use strict"

window.Stark or= {}

class Stark.App

  # attributes
  current_state: null
  states: {}
  template_root: ""

  # for collecting bootstrapped data
  data: {}

  router: new Stark.Router
  default_route: null

  constructor: ->
    # console.log "initializing router"
    @router.app = @
    @subscribe('app:route', @matchRoute)

  start: ->
    console.log("starting app")
    if !@router.start() && @default_route?
      console.log("no route matched, using default: #{@default_route}")
      @router.route(@default_route)
      @router.changeURL(@current_state.create_url())

  add_state: (state) ->
    s = new state()
    @states[s.name] = state
    state.app = @
    if s.url?
      @router.match(s.url, s.name)
    state

  # bound to app:route event
  matchRoute: (route, params) ->
    console.log "matchRoute()", route.state_name
    console.log route, "params: ", params
    @transition route.state_name, { params: params }

  transition: (state_name, state_data) ->
    console.log "transition", state_name, state_data
    target_state = @states[state_name]

    if ! target_state?
      return

    if @current_state instanceof target_state
      # TODO - verify params? models? some other way to make sure
      # its really the *same* state
      console.log "same state, canceling"
      return

    state_data or= {}
    if @data?
      _.extend state_data, @data
      @data = null # clear any bootstrapped data

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
      @current_state.dispose(state)

    # create views
    _.each state.views, (v) ->
      if @current_state? && _.include(state.no_redraw, v) && _.include(@current_state.views, v)
        console.log "not going to redraw #{v.name}"
        return

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
  # on the first hit. can be called multiple times
  #
  # @param [Object] data   Data to boostrap with, hash of models
  bootstrap: (data) ->
    data or= {}
    _.extend @data, data

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
