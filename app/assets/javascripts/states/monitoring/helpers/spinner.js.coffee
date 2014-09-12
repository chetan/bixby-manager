
_.extend Bixby.monitoring.Graph.prototype,

  # Dim the graph and show a spinner
  show_spinner: ->
    g = @dygraph
    return if !g._bixby_show_spinner
    el = g._bixby_el
    _.dim(el)

    spin_opts = {
      lines:     11,
      length:    9,
      width:     4,
      radius:    8,
      top:       0-$(el).height()/2 + "px",
      left:      $(el).width()/2-4 + "px"
    }
    g._bixby_spinner = new Bixby.view.Spinner($(el).parent(), spin_opts)

  # Undim and hide the spinner
  hide_spinner: ->
    g = @dygraph
    return if !g._bixby_spinner?
    g._bixby_spinner.stop()
    _.undim(g._bixby_el)
