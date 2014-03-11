
"use strict"

window.Stark or= {}

# Usage:
#
# When using the partial via @include_partial, the template will be wrapped in
# a span with a unique ID unless the first element is a TR or @wrap == false.
#
# This is necessary to locate and properly bind events in the resulting document,
# once everything has been rendered (e.g., once the parent view finishes rendering).

class Stark.Partial extends Stark.View

  # If ID is null, then one will be generated for you
  # id: null
  # className: null
  tagName: "div"

  # Reference to parent view
  parent: null

  # Whether or not to wrap with a span
  wrap: true

  initialize: (args) ->
    super(args)
    if !@id
      @id = "partial_" + Math.floor(Math.random()*10000)

  add_render_hook: (func) ->
    if @parent instanceof Stark.Partial
      @parent.add_render_hook(func)
    else if @parent
      @parent.after_render_hooks.unshift(func)

  redraw: ->
    @$el.html(@render_html())
    $("div#"+@id).html(@$el.html())
    @bind_events()
    @

  # Render the partial, setup its events and return its HTML
  render_partial_html: ->

    @$el.html(@render_html())

    # unless first element is a tr, wrap in a span
    first = @$el.children().first()
    if @wrap && first && first[0].tagName != "TR"
      @$el.html( "<div id='#{@id}'>" + @$el.html() + "</div>" )
    else
      first.attr("id", @id)

    # since html is being requested, setup a hook in the parent view
    # to make sure that any events will be correctly bound after loading
    p = @
    @add_render_hook ->
      p.post_render()

    return @$el.html()

  # Called by the parent view after it has completed rendering. Allows us to
  # bind any events in the case that we were setup via HTML injection into
  # the parent view's template
  post_render: ->
    @setElement( @parent.$("#" + @id) )
    @bind_events()
    return @
