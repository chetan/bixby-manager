
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTemplateView extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/check_template_view"

    bindings:
      "#name": "name"
      "#mode":
        observe: "mode"
        onGet: (val) ->
          _bm.CheckTemplate.mode_str(val)
      "#tags":
        observe: "tags"
        onGet: (val, opts) ->
          val.split(/,/).sort().join(", ")

    after_render: ->
      @stickit(@check_template)
      @
