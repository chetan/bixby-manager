
_.extend Bixby.monitoring.Graph.prototype,

  # Add mouseup/mousedown handlers for custom zoom/pan control
  #
  # We want to be able to programatically toggle between zoom & pan modes
  add_mouse_handlers: (opts) ->  ####
    # custom zoom/pan handling
    opts.interactionModel = _.clone(Dygraph.Interaction.defaultModel)

    opts.interactionModel.mousemove = (event, g, context) ->
      if context.isZooming
        Dygraph.moveZoom(event, g, context);
      else if context.isPanning
        context.is2DPan = false # override so we can always disable vertical (y-axis) panning
        Dygraph.movePan(event, g, context);

    # override mousedown to allow toggling pan mode
    opts.interactionModel.mousedown = (event, g, context) ->
      # Right-click should not initiate a zoom.
      if event.button && event.button == 2
        return

      g._bixby_dragging = true

      context.initializeMouseDown(event, g, context)

      if event.altKey || event.shiftKey || g._bixby_mode == "pan"
        if g._bixby_pan_start?
          g._bixby_pan_start()
        Dygraph.startPan(event, g, context)
      else
        Dygraph.startZoom(event, g, context)

    # override mouseup to load more data as we pan in either direction
    opts.interactionModel.mouseup = (event, g, context) ->
      g._bixby_dragging = false
      if context.isZooming
        Dygraph.endZoom(event, g, context)

      else if context.isPanning
        Dygraph.endPan(event, g, context)
        if g._bixby_pan_complete?
          g._bixby_pan_complete()
