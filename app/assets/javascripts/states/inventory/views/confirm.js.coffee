
namespace "Bixby.view", (exports, top) ->

  # opts keys:
  # title, message, shown_cb, hidden_cb
  class exports.Confirm extends Stark.View

    tagName: "div"
    className: "modal confirm"
    template: "inventory/_confirm"

    events: {
      "click button.proceed": (e) ->
        @confirmed = true
        @hide()

      "click button.cancel": (e) ->
        @confirmed = false
        @hide()

    }

    after_render: ->
      v = @

      if v.options.shown_cb
        @$el.on "shown.bs.modal", ->
          v.options.shown_cb.call(v, v.confirmed)

      if v.options.hidden_cb
        @$el.on "hidden.bs.modal", ->
          v.options.hidden_cb.call(v, v.confirmed)

      @$el.modal("show")

    hide: ->
      @$el.modal("hide")
