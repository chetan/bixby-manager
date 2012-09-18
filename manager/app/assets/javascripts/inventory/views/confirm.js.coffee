
namespace "Bixby.view", (exports, top) ->

  class exports.Confirm extends Stark.Partial

    tagName: "div"
    className: "modal"
    template: "inventory/_confirm"

    events: {
      "click button.proceed": (e) ->
        @confirmed = true
        @hide()

      "click button.cancel": (e) ->
        @confirmed = false
        @hide()

    }

    initialize: (title, message, shown_cb, hidden_cb) ->
      [@title, @message] = [title, message]
      super
      @render()
      v = @
      @$el.on "shown", ->
        if shown_cb
          shown_cb.call(v, v.confirmed)
      @$el.on "hidden", ->
        if hidden_cb
          hidden_cb.call(v, v.confirmed)
      @$el.modal({ show: true })

    hide: ->
      @$el.modal("hide")
