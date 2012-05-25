
"use strict"

window.Stark or= {}

class Stark.View extends Backbone.View

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "view"

  # [internal] Reference to the Stark::App instance
  app: null

  # [internal] Reference to the current Stark::State instance
  state: null

  # File name of the template rendered by this view
  template: null

  # Selector for element into which this view will be rendered
  # (usually a div or span). Can be a string (CSS selector) or
  # a function.
  selector: null

  # List of events to subscribe to at the @app level
  app_events: null

  # List of sub-views
  views: []

  initialize: ->
    _.bindAll @

  # Lookup @template in the global JST hash
  jst: ->
    JST[ @app.template_root + @template ]

  # Create a Template object for the configured @template
  #
  # In practice, this can be overidden to use your preferred
  # template library, as long as it responds to #render(context),
  # where context is a reference to the view itself.
  create_template: ->
    new Template(@jst())

  # Default implementation of Backbone.View's render() method. Simply renders
  # the @template into the element defined by @selector.
  #
  # Custom rendering should usually call super() before any additional
  # rendering.
  render: ->

    @log "rendering view", @
    @_template = @create_template()

    # use an optional [dynamic] selector
    el = null
    if @selector?
      if _.isFunction(@selector)
        el = @selector()
      else
        el = el
    else
      el = @el

    @setElement(el)
    @$el.html(@_template.render(@))
    @

  # Proxy for Stark.state#transition
  transition: (state_name, state_data) ->
    @state.transition(state_name, state_data)

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

  # Cleanup any resources used by the view. Should remove all views and unbind any events
  dispose: ->
    @$el.html("")
    @unbind_app_events()
    @undelegateEvents()
    for v in @views
      v.dispose()
