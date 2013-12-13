namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.Metric extends Stark.Partial

    className: "metric"
    template: "monitoring/_metric"

    after_render: ->

      metrics = @metric.collection

      # sync panning all graphs on page
      opts = {
        drawCallback: (g, isInitial) ->
          # only process this callback after the initial draw and
          # only for the graph which was clicked
          return if isInitial || metrics._blockRedraw || metrics._last_click != g
          metrics._blockRedraw = true

          range = g.xAxisRange()
          metrics.each (m) ->
            # redraw all graphs except the one which was panned (g)
            if m.graph && m.graph != g
              if _.isScrolledIntoView(m.graph._bixby_el, true)
                m.graph.updateOptions({
                  dateWindow: range,
                })
              else
                # defer range update til it comes into view
                m.graph._bixby_update_range = range

          metrics._blockRedraw = false
        }

      # selector for drawing the graph into
      @metric.graph = Bixby.monitoring.render_metric(@$el, @metric, opts)

      return if !@metric.graph?

      @metric.graph._bixby_mode = "pan" # only panning in list view, no zoom

      @metric.graph._bixby_pan_start = ->
        metrics._last_click = @ # store it so we can use it to filter redraws
        metrics._last_click_range = @xAxisRange()

      # fired when panning is completed on the given graph
      # update all other graphs with more data
      #
      # @param [Dygraph] g        the graph which was just panned
      @metric.graph._bixby_pan_complete = ->
        # bail if X range did not change
        return if @xAxisRange()[0] == metrics._last_click_range[0]
        metrics._last_click = metrics._last_click_range = null

        metrics.each (m) ->
          if m.graph && m.graph != @
            if _.isScrolledIntoView(m.graph._bixby_el, true)
              Bixby.monitoring.load_more_data(m.graph, m)
            else
              # defer loading of graphs that aren't visible
              m.graph._bixby_needs_more_data = true

          # update x-axis
          if m.graph && m.graph._bixby_update_range?
            m.graph.updateOptions({
              dateWindow: m.graph._bixby_update_range,
            })
            m.graph._bixby_update_range = null

