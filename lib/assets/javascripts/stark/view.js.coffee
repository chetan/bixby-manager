
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

  # Object containing helper functions to attach to views
  @helpers: {}

  # File name of the template rendered by this view
  template: null

  # Hash of links to create and bind.
  # The keys are selectors and the value is an array. The first element of the
  # array is the state name which will be activated when the link is clicked,
  # and the second value is a hash of data models to pass into the new state.
  #
  # Instead of a hash, a function may be passed which would be called onClick.
  # The result of this function should be a hash of models.
  #
  # Examples:
  #
  #   Simple links:
  #
  #     links:
  #       "a.brand": "inventory"
  #       ".tab.monitoring a": [ "monitoring", { foo: "bar" } ]
  #
  #   Using a function:
  #
  #     links:
  #       ".monitoring_host_link": [ "mon_view_host", (el) ->
  #         return { host: @host }
  #       ]
  #
  #   Using a function makes sure you get the correct context
  #
  links: null

  # A selector for an input element which should receive focus on render
  focus: null

  # List of events to subscribe to at the @app level
  app_events: null

  # List of models to bind to this view
  bindings: null

  # Set true to avoid redrawing on state changes
  reuse: false

  # List of sub-views
  views: null

  # List of post-render hooks
  after_render_hooks: null

  # used for stickit binding
  model: null
  _stickit: null

  # internal attributes (initialized in constructor below)
  _data: null
  _views: null

  # Get the class name for this instance
  #
  # @return [String]
  getClassName: ->
    /(\w+)\(/.exec(this.constructor.toString())[1]

  # Called from Backbone.View constructor
  initialize: (args) ->
    @_data = []
    @views = []
    @after_render_hooks = []
    if _.isObject(args)
      _.extend @, args
      for v in _.values(args)
        if v instanceof Stark.Model
          @_data.push(v)

    # mixin view helpers
    if Stark.View.helpers
      _.extend @, Stark.View.helpers
    if @helpers
      _.each @helpers, (h) => _.extend(@, h)

    # _.bindAll @, _.functions(@) # don't think this is even needed
    return @

  # Cleanup any resources used by the view. Should remove all views and unbind any events
  dispose: ->
    @log "disposing of view #{@getClassName()}"
    @$el.html("")
    @stopListening()
    @unstickit()
    @unbind_app_events()
    @undelegateEvents()
    @unbind_models()
    for v in @views
      v.dispose()
    @views = []



  # Rendering methods
  # ================================================================================================

  # Default implementation of Backbone.View's render() method. Simply renders
  # the @template into the element defined by @selector.
  #
  # Custom rendering should usually call super() before any additional
  # rendering and always return itself.
  #
  # @return [Bixby.View] returns the view for chaining
  render: ->
    @before_render()
    @$el.html(@render_html())
    @bind_events()
    return @

  # Actions to perform before rendering the view template (e.g., massage data)
  #
  # Default: noop
  before_render: ->
    # noop

  # Actions to perform after rendering (e.g., attach custom events, jquery
  # plugins, etc)
  #
  # Default: noop
  after_render: ->
    # noop

  # Redraw the view, taking care to first dispose of any events and subviews
  redraw: ->
    @dispose()
    @render()

  # Lookup @template in the global JST hash
  jst: (tpl) ->
    tpl ||= @template
    @log "render #{tpl}" #,"\n\t\t\t", @
    JST[tpl] || JST["states/#{tpl}"]

  # Create a Template object for the configured @template
  #
  # In practice, this can be overidden to use your preferred
  # template library, as long as it responds to #render(context),
  # where context is a reference to the view itself.
  #
  # @param [String] src       Contents of the template
  #
  # @return [Template]
  create_template: (src) ->
    new Template(src)

  # Render the configured @template to HTML
  render_html: ->
    tpl = @jst()
    return "" if not @template? or not tpl
    try
      return @create_template(tpl).render(@)
    catch ex
      @log "error while rendering template '#{@template}': #{ex.message}"
      throw ex

  # Get or set the view's html.
  #
  # See also: jQuery.html()
  html: (args...) ->
    @$el.html(args...)

  # Set the given data/model on the view
  #
  # @param [String] key
  # @param [Object] val
  set: (key, val) ->
    @_data.push(val)
    @[key] = val



  # DOM Events & model binding
  # ================================================================================================

  # Bind all events
  bind_events: ->
    @hide_elements()
    @refreshUi(@ui)
    @bind_app_events()
    @bind_link_events()
    @bind_models()
    _.eachR @, @after_render_hooks, (hook) ->
      hook.call(@)
    @set_focus()
    @after_render()

  # Process @links hash and attach events
  bind_link_events: ->

    # @log "bind_link_events", @

    if not @links?
      # @log "binding events: ", @events
      @delegateEvents(@events)
      return

    link_events = @events || {}

    # @log "looking for link events", _.keys(@links), @$el

    _.eachR @, @links, (link, sel) -> # loop over each link definition

      _.eachR @, @$(sel), (el) -> # loop over each matching link

        if !_.isArray(link)
          link = [link] # handle simple string values

        state = link[0]
        data = null
        if link.length > 1
          data = link[1]

        # setup delegate event
        link_events["click " + sel] = (e) ->
          if e.altKey || e.ctrlKey || e.metaKey || e.shiftKey
            return # let click go through (new tab, etc)

          # stop normal click event (navigate to href)
          # so we can instead do some internal routing (transition)
          e.preventDefault()
          @transition(state, @get_link_data(data, e.target))

        return if not @app.states[state]?

        # create url for the state with the required data from this view
        s = new @app.states[state]()
        _.extend s, @get_link_data(data, el)

        url = s.create_url()
        url = "/" + url if url && url.charAt(0) != '/'

        @$(el).attr("href", url)

    # @log "binding link events: ", link_events
    @delegateEvents(link_events)

  # Helper for resolving data to a set of actual values
  #
  # @param [Object] data    Data hash
  # @param [Element] el     Element which data should be generated for (in the function case)
  get_link_data: (data, el) ->
    ret = {}

    if not data?
      return ret

    if _.isArray(data)
      _.eachR @, data, (key) ->
        ret[key] = @[key]

    else if _.isFunction(data)
      data = data.call(@, el)
      _.eachR @, data, (val, key) ->
        ret[key] = val

    return ret

  # Bind all the models specified in @bindings
  bind_models: ->
    # @log "binding models for view ", @
    return if not @bindings?
    for m in @bindings
      if @[m]?
        @unbind_model( @[m] )
        @bind_model( @[m] )

  # Bind a method to the given model, using this View as the context
  #
  # @param [Model] model
  bind_model: (model) ->
    model.bind_view(@)

  # Subscribe to all @app level events as defined in the @app_events var
  bind_app_events: ->
    _.eachR @, @app_events, (cb, key) ->
      @app.subscribe(key, cb, @)

  # Unsubscribe all @app level events (see #bind_app_events)
  unbind_app_events: ->
    _.eachR @, @app_events, (cb, key) ->
      @app.unsubscribe(key, cb, @)

  # Unbind all models from this view
  unbind_models: ->
    for m in @_data
      @unbind_model(m)

  # Unbind the given model from this view
  #
  # @param [Model] m
  unbind_model: (m) ->
    if _.isObject(m) && _.isFunction(m["unbind_view"])
      m.unbind_view(@)
    else if _.isArray(m)
      for mm in m
        @unbind_model(mm)

  set_focus: ->
    return if !@focus
    @$(@focus).focus()

  hide_elements: ->
    @$(".start_hidden").hide()

  # Bind to view with stickit and enable validation if model has any configured
  stickit: (model) ->
    @model = @_stickit = model
    super

    if ! _.isEmpty(model.validation)
      # add validation
      opts = {
        forceUpdate: true

        valid: (view, attr) ->
          view.valid(attr)

        invalid: (view, attr, error) ->
          view.invalid(attr, error)
      }
      Backbone.Validation.bind(@, opts)

  valid: (attr) ->
    _.pass @$("div.valid.#{attr}")

  invalid: (attr, error) ->
    _.fail @$("div.valid.#{attr}"), error




  # Methods dealing with partials, includes, etc.
  # ================================================================================================

  # Summary:
  #
  # include            Raw include of the contents of some other template (used in templates)
  # include_partial    Create partial class and return HTML (used in templates)
  # partial            Render a partial (sub) view into the given selector (used in views)
  #
  #
  # includes can be called like
  #
  # <%= include(...) %>
  #  or
  # __out__ += include(...)
  #
  # from within anywhere in a template


  # A raw include of the contents of some other template. It will be bound with
  # the the same variables in this view.
  # The target template is rendered as plain text with no events or other bindings.
  #
  # NOTE: This should be called from within a template
  #
  # @param [String] tpl     Template to include
  # @param [Object] data    Optional data to include in context
  #
  # @return [String] html
  include: (tpl, data) ->
    @log "include #{tpl}"
    data = _.extend({}, @, data)
    tpl_content = @jst(tpl)
    if ! tpl_content?
      @error "failed to locate to locate tpl:", tpl
      return "ERROR: MISSING TPL"

    try
      return @create_template(tpl_content).render(data)
    catch ex
      @log "error while rendering template '#{tpl}': #{ex.message}"
      throw new Error("failed to include '#{tpl}'")

  # Create a partial, setup its events, and return the HTML
  #
  # NOTE: This should be called from within a template
  #
  # @param [Class] clazz      class name of view to render
  # @param [Object] data      context data for partial
  #
  # @return [String] html
  include_partial: (clazz, data) ->
    return @create_partial(clazz, data).render_partial_html()

  # Create a partial for each object in the given collection
  #
  # @param [Stark.Collection] collection        can be of type Collection or Array
  # @param [String] context                     context var to assign when passing data to view
  # @param [Class] clazz                        class name of partial view to render
  #
  # @return [String] html
  each_partial: (collection, context, clazz) ->
    [s, v] = ["", @]

    if collection instanceof Stark.Collection
      collection.each (obj) ->
        ctx = {}
        ctx[context] = obj
        s += v.include_partial(clazz, ctx)

    else
      _.each collection, (obj) ->
        ctx = {}
        ctx[context] = obj
        s += v.include_partial(clazz, ctx)

    return s

  # Render a partial (sub) view into the given selector
  #
  # NOTE: this should be called from within a View class
  #
  # @param [Class] clazz      class name of view to render
  # @param [Object] data      context data for partial
  # @param [String] selector  optional CSS selector into which the partial view will be rendered
  #
  # @return [Bixby.Partial] view instance
  partial: (clazz, data, selector) ->
    v = @create_partial(clazz, data)
    if selector?
      v.setElement( @$(selector) )
    v.render()
    return v

  # Instantiate a partial class with the given data
  #
  # @param [Class] clazz
  # @param [Object] data
  #
  # @return [Object] view class instance
  create_partial: (clazz, data) ->

    # copy state data and override with passed in props
    data = _.extend({}, @state._data, data)
    data.app = @app
    data.state = @state

    v = null
    if _.isObject(clazz)
      v = new clazz(data)

    else if _.isString(clazz)
      # assume its a template name, create a generic instance
      v = new Stark.Partial(data)
      v.template = clazz

    @views.push(v)
    v.parent = @
    return v



  # Utility methods for use within view & view helpers
  # ================================================================================================

  # Proxy for Stark.state#transition
  transition: (state_name, state_data) ->
    @state.transition(state_name, state_data)

  # Fetch the values for the named attributes in this view.
  # This is a simple helper for retrieving values from forms.
  #
  # @param [String] names
  #
  # @return [Object] key/value pairs
  get_attributes: (names) ->
    ret = {}
    for name in arguments
      if name.indexOf(".") >= 0 or name.indexOf("#") >= 0
        # use name directly if it contains a selector
        ret[name] = _.val(@$(name))
      else
        # try to select by id or classname
        ret[name] = _.val(@$("##{name}")) || _.val(@$(".#{name}"))

    return ret
