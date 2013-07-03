
"use strict"

window.Stark or= {}

class Stark.Partial extends Stark.View

  # Randomly generated span ID used for HTML injection workaround
  span_id: null

  # Reference to parent view
  parent: null

  initialize: (args) ->
    super(args)
    @span_id = "partial_" + Math.floor(Math.random()*10000000)

  add_render_hook: (func) ->
    if @parent instanceof Stark.Partial
      @parent.add_render_hook(func)
    else
      @parent.after_render_hooks.unshift(func)

  get_html: ->
    # since html is being requested, setup a hook in the parent view
    # to make sure that any events will be correctly bound after loading
    p = @
    @add_render_hook ->
      p.post_render()

    return "<span id='#{@span_id}'>" + @$el.html() + "</span>"

  # Called by the parent view after it has completed rendering. Allows us to
  # bind any events in the case that we were setup via HTML injection into
  # the parent view's template
  post_render: ->
    @setElement( @parent.$("span#" + @span_id) )
    @bind_link_events()
    @bind_models()
    @after_render()
    return @
