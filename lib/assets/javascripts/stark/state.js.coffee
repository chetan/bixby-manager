
"use strict"

window.Stark or= {}

class Stark.State

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "state"

  # mixin events
  _.extend @.prototype, Backbone.Events

  # [internal] Reference to the Stark::App instance
  app: null

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

  # Route instance that reprsents this State
  route: null

  # List of views used by this state
  views:  null

  # Hash of models required by this state and its views. Models will be autolaoded
  # when the state is created. Views will only be rendered once loads are complete.
  #
  # { key: ModelClass }
  #
  # Once loaded, keys will be available directly within the state and view, as well as
  # in templates.
  models: null

  # List of events to subscribe to at the @app level
  app_events: null

  constructor: ->
    # internal attributes
    @_views = []

  # Transition to another state
  #
  # This simply calls @app.transition()
  #
  # @param [String] state_name    name of the target state
  # @param [Hash] state_data      data to pass into the target state
  transition: (state_name, state_data) ->
    @app.transition(state_name, state_data)

  # Copy state_data into the local scope
  # Return an array of any missing models so they can be loaded
  load_data: (data) ->
    @current_user = data.current_user
    needed = []
    _.eachR @, @models, (model, key) ->
      if data[key]
        # copy into current [state] scope
        @[key] = data[key]

      else if _.isObject(model)
        # create new model to be fetched
        @[key] = new model(data)
        @log "will ajax load:", @[key]
        needed.push @[key]

    return needed

  # This is called by Stark when the state is loaded but just before rendering.
  # Must always return true when validate succeeds.
  #
  # A good place to, say, transition away to some other state if we are
  # missing data, etc.
  #
  # @return [Boolean] something other than true to cancel navigation
  validate: ->
    return true

  # This is called by Stark when this state becomes active (transitioning TO),
  # after all data has been loaded and views have been rendered.
  #
  # optional, if extra setup is needed
  activate: ->
    # NO-OP

  # This is called by Stark when this state becomes deactive (transitioning AWAY),
  # before dispose() is called
  #
  # optional, if extra teardown is needed (beyond normal dispose())
  deactivate: ->
    # NO-OP

  # Return the URL that represents this state (substituting any params in @url)
  #
  # While @url is used matching URLs to States, create_url() is used for updating
  # the url in the address bar or creating a link to the state
  create_url: ->
    url = @url
    for name in @route.paramNames
      if name.match(/_id$/)
        v = name.replace(/_id$/, '')
        if @[v]
          url = url.replace(":#{name}", @[v].id)

      else if @[name] and _.isString(@[name])
        url = url.replace(":#{name}", @[name])


    return url

  # Cleanup any resources used by the state. Should remove all views and unbind any events
  dispose: (new_state) ->
    @log "disposing of state", @name, @
    @unbind_app_events()
    _.each @_views, (v) ->
      if ! (_.any(new_state.views, (n)-> v instanceof n) && v.reuse == true)
        # only dispose of view IF NOT required by new state
        v.dispose()
    , @

  # Subscribe to all @app level events as defined in the @app_events var
  bind_app_events: ->
    _.each @app_events, (cb, key) ->
      @app.subscribe(key, cb, @)
    , @

  # Unsubscribe all @app level events (see #bind_app_events)
  unbind_app_events: ->
    _.each @app_events, (cb, key) ->
      @app.unsubscribe(key, cb, @)
    , @
