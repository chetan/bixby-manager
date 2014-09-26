namespace "Bixby.view", (exports, top) ->

  class exports.CommandLogModal extends Stark.Partial

    tagName: "div"
    className: "modal command_log_modal"
    template: "runbooks/_command_log_modal"

    show: ->
      @$el.modal("show")

    after_render: ->
      @$el.modal({ show: false })
      @$el.on "hidden.bs.modal", (e) =>
        # remove from DOM once hidden, no need to stick around. just recreate next time
        @$el.remove()
