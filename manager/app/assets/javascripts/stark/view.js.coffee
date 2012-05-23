
"use strict"

window.Stark or= {}

class Stark.View extends Backbone.View

  state: null
  template: null
  app_events: null
  selector: null
  views: [] # sub-views

  initialize: ->
    _.bindAll @

  tpl_path: ->
    @app.template_root + @template

  render: ->
    console.log "rendering view", @
    @_template = new Template(JST[ @tpl_path() ])

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

  # proxy for Stark.state#transition
  transition: (state_name, state_data) ->
    @state.transition(state_name, state_data)

  bind_app_events: ->
    _.each @app_events, (cb, key) ->
      @app.subscribe(key, cb)
    , @

  dispose: ->
    @$el.html("")
    @undelegateEvents()
    for v in @views
      v.dispose()
