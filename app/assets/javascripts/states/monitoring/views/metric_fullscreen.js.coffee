namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.MetricFullscreen extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/metric_fullscreen"

    events: {}

    after_render: ->
      @graph = Bixby.monitoring.render_metric(@$("div.metric"), @metric)
