
_.extend Bixby.monitoring.Graph.prototype,

  # Add mouseup/mousedown handlers for custom zoom/pan control
  #
  # We want to be able to programatically toggle between zoom & pan modes
  #
  # NOTE: These handlers are copied and modified from the original.
  # See Dygraph.Interaction.defaultModel["mousedown/move/up"] events
  # If the above methods change in a new release, we need to modify the below to match
  add_mouse_handlers: (opts) ->  ####
    # custom zoom/pan handling
    opts.interactionModel = _.clone(Dygraph.Interaction.defaultModel)

    # override mousedown to allow toggling pan mode
    opts.interactionModel.mousedown = (event, g, context) ->

      # Create and register mousemove/mouseup events inside mousedown, same as in dygraph.js

      # override so we can always disable vertical (y-axis) panning (aka 2D)
      mousemove = (event) ->
        if context.isZooming
          # TODO skip distanceFromChart stuff for now (no access to that method)
          Dygraph.moveZoom(event, g, context);
        else if context.isPanning
          context.is2DPan = false
          Dygraph.movePan(event, g, context);

      # override mouseup to load more data as we pan in either direction
      mouseup = (event) ->
        if context.isZooming
          if context.dragEndX != null
            g._bixby_dragging = false
            Dygraph.endZoom(event, g, context)
          else
            Dygraph.endZoom(event, g, context)

        else if context.isPanning
          Dygraph.endPan(event, g, context)
          if g._bixby_pan_complete?
            g._bixby_pan_complete()

        Dygraph.removeEvent(document, 'mousemove', mousemove)
        Dygraph.removeEvent(document, 'mouseup', mouseup)
        context.destroy()

      # Right-click should not initiate a zoom.
      return if event.button && event.button == 2

      g._bixby_dragging = true

      context.initializeMouseDown(event, g, context)

      if event.altKey || event.shiftKey || g._bixby_mode == "pan"
        if g._bixby_pan_start?
          g._bixby_pan_start()
        Dygraph.startPan(event, g, context)
      else
        Dygraph.startZoom(event, g, context)

      g.addAndTrackEvent(document, 'mousemove', mousemove)
      g.addAndTrackEvent(document, 'mouseup', mouseup)
