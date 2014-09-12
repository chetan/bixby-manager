
_.extend Bixby.monitoring.Graph.prototype,

  touch_enabled: false

  # Override touch events to make them optional and implement custom pan events
  add_touch_handlers: (opts) ->

    use_touch = @touch_enabled
    opts.interactionModel.touchstart = (event, g, context) ->
      return if !use_touch
      g._bixby_dragging = true
      Dygraph.Interaction.startTouch(event, g, context)
      if g._bixby_pan_start?
        g._bixby_pan_start()

    opts.interactionModel.touchmove = (event, g, context) ->
      return if !use_touch
      context.touchDirections.y = false
      Dygraph.Interaction.moveTouch(event, g, context)

    opts.interactionModel.touchend = (event, g, context) ->
      return if !use_touch
      Dygraph.Interaction.endTouch(event, g, context)
      if g._bixby_pan_complete?
        g._bixby_pan_complete()
