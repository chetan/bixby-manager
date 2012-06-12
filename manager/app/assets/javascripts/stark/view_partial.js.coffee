
"use strict"

window.Stark or= {}
window.Stark.View or= {}

# Partials differ from normal Views in that they do not automatically render
# into the DOM. A Partial is always created from another View, usually as part of a
# collection; e.g., when rendering a list, a Partial would create each <li>
#
# Usage is similar to a View except instead of setting @selector, you set
# @tagName and, optionally, @className. The template will be rendered into a new
# element using that combination of properties. This element can then be inserted
# into the parent view either manually or via the View.partial() helper method.
class Stark.Partial extends Stark.View

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "partial_view"

  initialize: (args) ->
    super(args)
    @render()

  render: ->
    @log "render", @
    @$el.html(@render_html())
    @attach_link_events()
    @after_render()
    return @
