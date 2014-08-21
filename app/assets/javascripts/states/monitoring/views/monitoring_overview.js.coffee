namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MonitoringOverview extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/monitoring_overview"

    after_render: ->
      $(window).resize _.debounceR 500, =>
        @redraw()
