
_.extend Bixby.monitoring.Graph.prototype,

  # Add DOM elements for drawing an x-value crosshair and tooltip
  #
  # @param [jQuery] gc       div.graph_container jQuery object
  create_tooltip: (gc) ->
    gc.append('<div class="tooltip in value"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>')
    gc.append('<div class="line xline"></div>')
    gc.mouseout (e) =>
      @hide_tooltip(gc)

  # Hide the x-value crosshair and tooltip
  #
  # @param [jQuery] gc       div.graph_container jQuery object
  hide_tooltip: (gc) ->
    gc.find("div.line.xline").hide()
    gc.find("div.value.tooltip").hide()

  # Position x-value crosshair & draw value tooltip
  #
  # @param [Dygraph] g
  # @param [jQuery] el       div.graph element
  # @param [jQuery] gc       div.graph_container jQuery object
  # @param [Number] pX
  # @param [Number] pageY
  # @param [String] text     tooltip text to display
  show_tooltip: (g, el, gc, pX, pageY, text) ->
    xline = gc.find("div.line.xline")
    dVal = gc.find("div.value.tooltip")

    # only show x-line is NOT dragging (but still show the tooltip)
    x = el.position().left + pX
    if g._bixby_dragging
      xline.hide()
      if g._bixby_mode == "pan"
        dVal.hide()
        return # show nothing when panning
    else
      h = el.height()
      xline.css({
        height: h-20+"px" # remove 20px for the x-axis legend
        left:   x + "px"
      })
      xline.show()

    # tooltip placement
    opts = if pX > 300
      # show tooltip to the left of line
      dVal.addClass("left").removeClass("right")
      r = el.width() - x
      { right: r+"px", left: "auto" }
    else
      # right of line
      dVal.addClass("right").removeClass("left")
      { left: x+6+"px", right: "auto" } # extra 6px pad so the mouse cursor doesn't cover it

    # position near mousepointer
    pY = pageY-el.offset().top
    opts.top = pY + "px"

    dVal.find(".tooltip-inner").text(text)
    dVal.css(opts).show()
