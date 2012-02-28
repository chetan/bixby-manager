
jQuery ->
  if (!Backbone.history.start({ pushState: true }))
    Backbone.history.navigate("#inventory")
