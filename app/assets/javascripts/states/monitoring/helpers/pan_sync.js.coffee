
Bixby.monitoring ||= {}

# Wraps all functionality related to loading more data when panning the graph
class Bixby.monitoring.PanSyncHelper

  # @param [Array<Graph>] graphs
  constructor: (@graphs) ->
    @graphs = [ @graphs ] if !_.isArray(@graphs)
    @context = {}
    _.eachR @, @graphs, (g) -> @setup_pan_handler(@graphs, g, @context)
    @setup_document_handlers(@graphs, @context)


  # Document events
  #
  # @param [Array<Dygraph>] graphs
  # @param [Hash] context               for holding special state flags
  setup_document_handlers: (graphs, context) ->
    $(document).on "mouseup", (e) ->
      return if !context._last_click? || (e.target.tagName && e.target.tagName.toUpperCase() == "CANVAS")
      g = context._last_click
      g._bixby_pan_complete() if g?

    # attach pan scroll helper
    $("div.graph").appear()
    $(document.body).on "appear", "div.graph", _.debounceR 100, (e, appeared) ->
      # loop through appeared elements, match up with metric graph elements, and load data if necessary
      _.each appeared, (el) ->
        _.each graphs, (graph) ->
          return if !graph
          g = graph.dygraph
          if g._bixby_el == el && g._bixby_needs_more_data == true
            g._bixby_needs_more_data = false
            graph.load_more_data()


  # Pan events
  #
  # @param [Array<Dygraph>] graphs
  # @param [Dygraph] graph
  # @param [Hash] context               for holding special state flags
  setup_pan_handler: (graphs, graph, context) ->

    return if !graph?

    # sync panning all graphs on page
    opts =
      drawCallback: (g, isInitial) ->
        # only process this callback after the initial draw and
        # only for the graph which was clicked
        return if isInitial || context._blockRedraw || context._last_click != g
        context._blockRedraw = true

        range = g.xAxisRange()
        _.each graphs, (graph) ->
          # redraw all graphs except the one which was panned (g)
          if graph.dygraph && graph.dygraph != g
            if _.isScrolledIntoView(graph.dygraph._bixby_el, true)
              graph.dygraph.updateOptions({ dateWindow: range })
            else
              # defer range update til it comes into view
              graph.dygraph._bixby_update_range = range

        context._blockRedraw = false

    graph.dygraph.updateOptions(opts, true)

    graph.dygraph._bixby_pan_start = ->
      context._last_click = @ # store it so we can use it to filter redraws
      context._last_click_range = @xAxisRange()

    # fired when panning is completed on the given graph
    # update all other graphs with more data
    #
    # @param [Dygraph] g        the graph which was just panned
    graph.dygraph._bixby_pan_complete = ->
      # bail if X range did not change
      return if @xAxisRange()[0] == context._last_click_range[0]
      context._last_click = context._last_click_range = null

      _.eachR @, graphs, (graph) ->
        if graph.dygraph
          if _.isScrolledIntoView(graph.dygraph._bixby_el, true)
            graph.load_more_data()
          else
            # defer loading of graphs that aren't visible
            graph.dygraph._bixby_needs_more_data = true

          # update x-axis
          if graph.dygraph._bixby_update_range?
            graph.dygraph.updateOptions({ dateWindow: graph.dygraph._bixby_update_range })
            graph.dygraph._bixby_update_range = null
