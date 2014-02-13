
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTemplateRow extends Stark.Partial

    template: "monitoring/_check_template_row"

    bindings:
      "#name": "name"
      "#mode":
        observe: "mode"
        onGet: (val, opts) ->
          console.log "got val", val
          switch val
            when "ANY"
              "any tag matches"
            when "ALL"
              "all tags match"
            when "EXCEPT"
              "all or no tags, except the following"
      "#tags":
        observe: "tags"
        onGet: (val, opts) ->
          val.split(/,/).sort().join(", ")
      "#items":
        observe: "items"
        onGet: (val, opts) ->
          _.map(val, (c) -> return c.command.name).sort().join(", ")

    links:
      "a#name": [ "mon_check_template_view", (el) -> { check_template: @ct } ]

    events:
      "click button.pubkey": (el) ->
        el.preventDefault()
        @$(".modal").modal("show")
        @$("div.modal textarea").focus()

      "focusin div.modal textarea": _.select_text

    after_render: ->
      @stickit(@ct)
      @
