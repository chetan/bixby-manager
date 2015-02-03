
# stark.js = IRON.backbone.js

"use strict"

window.Stark or= {}

class Stark.App

  # attributes
  env: "development"
  current_user: null
  current_state: null
  states: {}

  # for collecting bootstrapped data
  data: {}

  router: new Stark.Router
  login_route: null
  default_route: null

  # Create a new Stark application
  #
  # @param [String] env             the environment in which we're running (e.g., Rails.env)
  # @param [String] login_route     route to forward to when user is not logged in
  # @param [String] default_route   default route to use when logged in
  constructor: (env, login_route, default_route) ->
    @env = env
    @login_route = login_route
    @default_route = default_route

    # env helpers
    if @env == "development"
      @dev = @development = true
      @prod = @production = false
    else
      @dev = @development = false
      @prod = @production = true

    @router.app = @
    @subscribe('app:route', @matchRoute)

  start: ->
    @log "stark.app.start()"

    # cleanup template namespace
    # removes /templates/ from the middle of the path string to make
    # referencing in views a bit cleaner
    #
    # also removes templates/ from the start
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

    if @data?
      @current_user = @data.current_user

    if !@current_user?
      @log "not logged in, sending to login page: #{@login_route}"
      @router.start({silent: true})
      @router.route(@login_route)
      return

    if !@router.start()
      # router.start() will fire an event which calls the correct controller if a route was matched
      # otherwise we enter here and figure out what to do
      @log "no routes matched"
      if @current_user?
        @log "appear to be logged in, using default route: #{@default_route}"
        return @router.route(@default_route)

      @log "sending to login page: #{@login_route}"
      @router.route(@login_route)

  # Shorthand method for registering an array of states
  #
  # @param [Object] opts              common options to apply to all states
  # @param [Object] states            name = state name, value = object defininig the state prototype or a class
  add_states: (opts, states) ->
    if !states?
      states = opts
      opts = null

    if opts
      views = opts.views # views common to all states
      delete opts.views
    else
      views = []

    _.eachR @, states, (obj, name) ->
      if _.isFunction(obj)
        clazz = obj
      else
        clazz = class extends Stark.State
        _.extend(clazz.prototype, obj)

      clazz.prototype.name = name
      clazz.prototype.views = views.concat(clazz.prototype.views || []) # prepend common views
      _.extend(clazz.prototype, opts)
      @add_state(clazz)

  # Register a new state with the router
  #
  # @param [State] state
  add_state: (state) ->
    s = new state()
    @states[s.name] = state
    state.prototype.app = @
    if s.url?
      if matches = s.url.match(/^\/+(.*)$/)
        # strip any leading slashes so we can route correctly
        s.url = matches[1]
      state.prototype.route = @router.match(s.url, s.name)

  # bound to app:route event which is triggered by Route.handler method
  # will get triggered whenever user uses back/forward browser nav
  matchRoute: (route, params) ->
    @log "matchRoute()", route.state_name, "params:", params
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

    timer_name = "transition_to: " + state_name
    @start_timer(timer_name)

    @log "---"
    @begin_group("transition to: #{state_name}")
    @log "transition data:", state_data

    @trigger "before:transition", state_name, state_data
    target_state = @states[state_name]

    if ! target_state?
      # TODO error handler?
      @error "tried to transition to non-existent state ", state_name
      @end_group()
      @stop_timer(timer_name)
      return

    if @current_state instanceof target_state
      # TODO - verify params? models? some other way to make sure
      # its really the *same* state
      # maybe just url since each state should have a unique url?
      @log "same state, should we cancel transition?"
      # return

    state_data or= {}
    if @data?
      @current_user = @data.current_user
      _.extend state_data, @data

      # clear any bootstrapped data, but store a backup copy
      @bootstrap_data = @data
      @data = null

    state_data.current_user = @current_user
    @log "got state_data", state_data

    state = new @states[state_name](@, state_data)

    # load data into state, retrieve models which are missing
    needed = state.missing_data
    if !(needed? && needed.length > 0)
      @change_state(state, timer_name)
      return true

    # load needed data before continuing
    Backbone.multi_fetch needed, {initial_load: true}, (err, results) =>
      if err and err.status >= 400 and err.status < 500
        # session timeout
        @redir = [ state_name, state_data ]
        state.dispose() # trash state we were building
        @redir_to_login()
        return

      @change_state(state, timer_name)

    true

  # Change to the given state
  #
  # @param [State] state
  change_state: (state, timer_name) ->
    @log "change_state()"

    if @current_state?
      @trigger("state:deactivate", @current_state)
      @current_state.deactivate()
      @current_state.dispose(state)

    try
      if state.validate() != true
        # short-circuit this state
        @log "new state validation failed, canceling activation", state
        @trigger("state:deactivate", state)
        state.deactivate()
        state.dispose(state)
        return

      @trigger("state:before_activate", @)
      state.render()

    catch ex
      # log and re-raise so it's seen at the top level in the console (not hidden in a group)
      @log "caught exception"
      @log ex
      throw ex

    finally
      @end_group()
      @stop_timer(timer_name)

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

  redir_to_login: ->
    @log "redir_to_login()"
    window.location = @login_route


  # Setup pub/sub
  _.extend @.prototype, Backbone.Events

  # Create Publish/Subscribe aliases
  subscribe   : Backbone.Events.on
  unsubscribe : Backbone.Events.off
  publish     : Backbone.Events.trigger

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "app"
