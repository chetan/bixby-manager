namespace "Bixby.view", (exports, top) ->

  class exports.ConfirmPassword extends Stark.View

    tagName:   "div"
    className: "modal confirm"
    template:  "main/confirm_password"

    events:
      "click button.confirm": (e) ->
        pw = _.val(@$("input.password"))
        @current_user.confirm_password pw, (confirmed) =>
          @$el.modal("hide")
          @cb.call(@, confirmed)

      "click button.cancel": (e) ->
        @$el.modal("hide")
        @cb.call(@, false)

    after_render: ->
      @$el.modal("show")
      @$("input#password").focus()
