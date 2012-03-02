
# stark.js = IRON.backbone.js

#= require "stark_router"

"use strict"

window.Stark or= {}

# -----------------------------------------------------------------------------
Stark.Obj = class Obj

  # attributes
  # app - reference to app we belong to
  app: null

  constructor: (app) ->
    @app = app



# -----------------------------------------------------------------------------
class Stark.App
  _.extend @, Backbone.Events

  # attributes
  current_state: null
  states: {}

  # manages all app data
  data: {}

  router: new Stark.Router

  constructor: ->
    # console.log "initializing router"
    @router.app = @
    @subscribe('app:route', @matchRoute)

  add_state: (state) ->
    # console.log "add_state"
    s = new state
    @states[s.name] = state
    state.app = @
    @router.match(s.url, s.name)
    state

  # bound to app:route event
  matchRoute: (route, params) ->
    # console.log "matchRoute()", route.state_name
    # console.log route, params
    @transition_to route.state_name

  transition_to: (state_name, models...) ->
    console.log "transition_to", state_name, models...

    data = @data
    prev = @current_state

    state = new @states[state_name]
    state.app = @


    # make sure we have needed data, somewhere
    state_data = {}
    _.each state.models, (m, key) ->
      if new m() instanceof Backbone.Collection
        # console.log m.name
        model = data[m.name]
        # if m.length == 0
          # console.log "going to fetch: #{m}"
          # m.fetch

      else
        # single object required, should have been passed
        # lets validate that we got it in models
        console.log("TODO single obj")

      # TODO this should be a callback since fetches above will be async
      state_data[key] = model


    console.log "got state_data", state_data


    # TODO implement no_redraw
    # create views
    _.each state.views, (v) ->
      console.log "creating view #{v.name}"
      view = new v($("div.inventory_content"))
      _.extend(view, state_data)
      view.app = @
      view.state = state

      # console.log "view: ", view
      view.render()




  # method used by Server-side template to bootstrap any models
  # on the first hit
  #
  # @param [String] model  Model to bootstrap
  # @param [Object] data   Data to boostrap with, single Object or Array
  bootstrap: (model, data) ->
    # console.log "bootstrapping data #{model}"
    fn = if _.isString(model) then @locate_model_by_name(model) else model
    if ! fn? and _.isFunction(fn)
      # TODO raise err
      console.log "failed to find model for #{model}", fn

    if ! _.isArray(data)
      data = [ data ]

    obj = new fn()
    obj.reset(data)
    @data[fn.name] = obj
    # console.log "loaded data", @data


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



  # Create Publish/Subscribe aliases
  subscribe   : Backbone.Events.on
  unsubscribe : Backbone.Events.off
  publish     : Backbone.Events.trigger




# -----------------------------------------------------------------------------
class Stark.State extends Stark.Obj
  _.extend @, Backbone.Events

  # attributes
  name:   null
  url:    null
  views:  []
  models: []
  events: {}

  # transition TO the given state
  transition: (to_state, models...) ->
    console.log @
    @app.transition_to(to_state, models...)

  # this is called by Stark when this state becomes active (transitioning TO)
  # optional, if extra setup is needed
  activate: ->
    # NO-OP

  # this is called by Stark when this state becomes deactive (transitioning AWAY)
  # optional, if extra teardown is needed
  deactivate: ->
    # NO-OP



# -----------------------------------------------------------------------------
class Stark.View extends Backbone.View
  _.extend @, Stark.Obj

  state: null

  # proxy for Stark.state#transition
  transition: (to_state, models...) ->
    @state.transition(to_state, models...)

