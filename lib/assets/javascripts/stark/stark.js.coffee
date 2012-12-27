
# stark.js = IRON.backbone.js

"use strict"

window.Stark or= {}

class Stark.App

  # attributes
  current_state: null
  states: {}

  # for collecting bootstrapped data
  data: {}

  router: new Stark.Router
  default_route: null

  constructor: ->
    @router.app = @
    @subscribe('app:route', @matchRoute)

  start: ->
    @log "stark.app.start()"

    # cleanup template namespace
    # removes /templates/ from the middle of the path string to make
    # referencing in views a bit [c]leaner
    #
    # also removes templates/ from the start
    t = @
    r = /\/templates\//
    s = /^templates\//
    _.each _.keys(JST), (k) ->
      kp = null
      if r.test(k)
        kp = k.replace(r, '/')
      if s.test(k)
        kp = k.replace(s, '')
      if kp and not JST[kp]
        JST[kp] = JST[k]


    if !@router.start() && @default_route?
      @log "no routes matched, using default: #{@default_route}"
      @router.route(@default_route)

  add_state: (state) ->
    s = new state()
    @states[s.name] = state
    state.prototype.app = @
    if s.url?
      state.prototype.route = @router.match(s.url, s.name)

  # bound to app:route event which is triggered by Route.handler method
  # will get triggered whenever user uses back/forward browser nav
  matchRoute: (route, params) ->
    @log "matchRoute()", route.state_name
    @log route, "params: ", params
    @transition route.state_name, { params: params } # transition and pass in params


  # Transition to another state, optionally with the given data
  #
  # How this works:
  #
  # transition( "foo", { baz: 'bar' } )
  #
  # - create new state instance
  # - wire up instance with app reference
  # - bind app events
  # - copy bootstrapped and passed in data into state
  # - see if any more data needs to be loaded
  # - if not, render views right away
  # - else, load data via ajax then render views
  #
  transition: (state_name, state_data) ->
    @log "transition", state_name, state_data
    @trigger "before:transition", state_name, state_data
    target_state = @states[state_name]

    if ! target_state?
      # TODO error handler?!
      return

    if @current_state instanceof target_state
      # TODO - verify params? models? some other way to make sure
      # its really the *same* state
      @log "same state, should we cancel transition?"
      # return

    state_data or= {}
    if @data?
      @current_user = @data.current_user
      _.extend state_data, @data
      @data = null # clear any bootstrapped data

    state = new @states[state_name]()
    state.app = @
    state.bind_app_events()
    state.params = state_data.params if state_data.params?

    state_data.current_user = @current_user
    @log "got state_data", state_data

    # load data into state, retrieve models which are missing
    needed = state.load_data(state_data)
    if needed? && needed.length > 0
      app = @
      Backbone.multi_fetch needed, (err, results) ->
        app.render_views(state)
    else
      @render_views(state)

    @log "---"

  # Copy all of the known model data from state into the view
  #
  # @param [State] state
  # @param [View] view
  copy_data_from_state: (state, view) ->
    return if not state.models?
    _.each _.keys(state.models), (key) ->
      view.set key, state[key]

  # Render the State
  #
  # @param [State] state
  render_views: (state) ->
    @log "render_views "

    if @current_state?
      @trigger("state:deactivate", @current_state)
      @current_state.deactivate()
      @current_state.dispose(state)


    # create views
    _.eachR @, state.views, (v) ->

      if @current_state? && _.include(@current_state.views, v) && v.prototype.reuse == true
        @log "not going to redraw #{v.name}"
        state._views.push _.find(@current_state._views, (i) -> i instanceof v)
        return

      @log "creating view #{state.name}::#{v.name}"
      view = new v()
      view.set "current_user", @current_user
      @copy_data_from_state state, view
      view.app = @
      view.state = state
      view.render()
      state._views.push view

    if @current_state? && state.url? && (!state.params? || state.params.changeURL == true)
      # there was a previous state, update browser url
      # does not fire when using back/forward buttons as params.changeURL will be false
      @router.changeURL state.create_url()

    state.activate()
    @current_state = state
    @trigger("state:activate", state)


  # Method used by Server-side template to bootstrap any models
  # on the first hit. Can be called multiple times
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
    base or= window

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

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "app"
