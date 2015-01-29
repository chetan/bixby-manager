namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MonitoringOverview extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/monitoring_overview"

    after_render: ->
      $(window).on "resize.monitoring.overview", _.debounceR 500, =>
        @redraw()

    dispose: ->
      super
      $(window).off "resize.monitoring.overview"
