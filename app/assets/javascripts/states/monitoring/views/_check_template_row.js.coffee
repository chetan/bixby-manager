
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTemplateRow extends Stark.Partial

    template: "monitoring/_check_template_row"

    bindings:
      "#name": "name"
      "#mode":
        observe: "mode"
        onGet: (val, opts) ->
          _bm.CheckTemplate.mode_str(val)
      "#tags":
        observe: "tags"
        onGet: (val, opts) ->
          val.split(/,/).sort().join(", ")
      "#items":
        observe: "items"
        onGet: (val, opts) ->
          _.map(val, (c) -> return c.command.name).sort().join(", ")

    links:
      "a#name": [ "mon_check_template_view", (el) -> { check_template: @check_template } ]

    after_render: ->
      @stickit(@check_template)
      @
