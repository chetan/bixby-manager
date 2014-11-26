
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

  # internal attributes (initialized in constructor below)
  _data: null
  _views: null


  # Get the classname for this instance
  #
  # @return [String]
  getClassName: ->
    /(\w+)\(/.exec(this.constructor.toString())[1]

  constructor: (app, data) ->
    # internal attributes
    @_data  = {}
    @_views = []

    return if !app?

    @app = app
    @missing_data = @load_data(data)
    @bind_app_events()

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
    @params       = data.params
    @current_user = data.current_user

    needed = []

    # copy data into state scope
    _.eachR @, data, (obj, key) ->
      @[key] = @_data[key] = obj

    # check for missing models
    _.eachR @, @resolve_models(), (model, key) ->
      if _.isObject(model) && !@[key]
        # create new model to be fetched
        @[key] = @_data[key] = new model(data)
        @log "will ajax load:", @[key]
        needed.push @[key]

    return needed

  # Return the URL that represents this state (substituting any params in @url)
  #
  # While @url is used matching URLs to States, create_url() is used for updating
  # the url in the address bar or creating a link to the state
  create_url: ->
    url = @url

    if url[0] == '#'
      return window.location.pathname + url

    for name in @route.paramNames
      if name.match(/_id$/)
        if @[name] # see if we have 'foo_id'
          url = url.replace(":#{name}", @[name])

        # see if we have the model 'foo' itself
        v = name.replace(/_id$/, '')
        if @[v] && @[v].id
          url = url.replace(":#{name}", @[v].id)
        else
          @log "WARNING: couldn't find substitution for #{name} in #{@url}"
          return false

      else if @[name] and _.isString(@[name])
        url = url.replace(":#{name}", @[name])

    return url

  # This is called by Stark when the state is loaded but just before rendering.
  # Must always return true when validate succeeds.
  #
  # A good place to, say, transition away to some other state if we are
  # missing data, etc.
  #
  # @return [Boolean] something other than true to cancel navigation
  validate: ->
    return true

  render: ->
    @log "render"
    current_state = @app.current_state
    _.each @views, (v) =>

      if current_state? && _.include(current_state.views, v) && v.prototype.reuse == true
        @log "not going to redraw #{v.name}"
        @_views.push _.find(current_state._views, (i) -> i instanceof v)
        return

      if !v?
        @log "null view in #{@name}: ", @views
        throw new Error("Encountered an undefined view class in state #{@name}")

      @begin_closed_group("creating view #{@name}::#{v.name}")
      view = new v()
      view.app = @app
      view.state = @

      # copy state data into view
      view.set "current_user", @current_user
      _.each @_data, (obj, key) ->
        view.set key, obj

      view.render()
      @_views.push view
      @end_group()

    if @url? && (!@params? || @params.changeURL == true || window.location.hash)
      # there was a previous state, update browser url
      # does not fire when using back/forward buttons as params.changeURL will be false

      if window.location.hash
        # a little hack to clear out the hash no matter what
        # may need to revisit this later
        history.replaceState({}, document.title, window.location.pathname)

      url = @create_url()
      if url == false
        @log "no url change due to missing param"
      else
        @log "updating url: ", url
        @app.router.changeURL url

      window.scroll(0, 0)
    else
      @log "no url change"

    @activate()
    @app.current_state = @
    @app.trigger("state:activate", @)


  # Redraw the current state
  redraw: ->
    @dispose(@)
    @render()

  # Redraw the current state
  refresh: ->
    @redraw()

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

  # Cleanup any resources used by the state. Should remove all views and unbind any events
  dispose: (new_state) ->
    @begin_closed_group("disposing of state #{@name}")
    @unbind_app_events()
    _.eachR @, @_views, (v) ->
      if ! (_.any(new_state.views, (n) -> n && v instanceof n) && v.reuse == true)
        # only dispose of view IF NOT required by new state
        v.dispose()
    @end_group()

  # Subscribe to all @app level events as defined in the @app_events var
  bind_app_events: ->
    _.eachR @, @app_events, (cb, key) ->
      @app.subscribe(key, cb, @)

  # Unsubscribe all @app level events (see #bind_app_events)
  unbind_app_events: ->
    _.eachR @, @app_events, (cb, key) ->
      @app.unsubscribe(key, cb, @)

  # Handle array form of @models
  resolve_models: ->

    if _.isArray(@models)
      ret = {}
      _.each @models, (model) ->
        ret[model.key] = model

      return ret

    if _.isObject(@models)
      return @models

