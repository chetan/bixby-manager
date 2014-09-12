
_.extend Bixby.monitoring.Graph.prototype,

  touch_enabled: false

  # Override touch events to make them optional and implement custom pan events
  add_touch_handlers: (opts) ->

    bixby_graph = @
    use_touch = @touch_enabled
    opts.interactionModel.touchstart = (event, g, context) ->
      return if !use_touch
      g._bixby_dragging = true
      bixby_graph.hide_tooltip()
      Dygraph.Interaction.startTouch(event, g, context)
      if g._bixby_pan_start?
        g._bixby_pan_start()

    opts.interactionModel.touchmove = (event, g, context) ->
      return if !use_touch
      context.touchDirections.y = false # disable panning along y-axis
      Dygraph.Interaction.moveTouch(event, g, context)

    opts.interactionModel.touchend = (event, g, context) ->
      return if !use_touch
      g._bixby_dragging = false
      Dygraph.Interaction.endTouch(event, g, context)
      if g._bixby_pan_complete?
        g._bixby_pan_complete()

    # show tooltip w/ value on tap event
    return if !(use_touch && @el.tap?)
    @el.tap (e) =>
      pX = e.pageX - @el.offset().left
      coord = @find_nearest_coord(pX)
      text = @metric.format_value(coord.point[1], coord.point[0])
      @show_tooltip(@dygraph, @el, pX, e.pageY, text)
