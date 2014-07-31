namespace "Bixby.view", (exports, top) ->

  class exports.ConfirmIdentity extends Stark.View

    tagName:   "div"
    className: "modal confirm"
    template:  "main/confirm_password"

    events:
      "click button.confirm": (e) ->
        @confirm()

      "click button.cancel": (e) ->
        @$el.modal("hide")
        @cb.call(@, false)

      "keypress input": (e) ->
        if e.keyCode == 13
          @confirm()

    confirm: ->
      pw = _.val(@$("input.password"))
      @current_user.confirm_password pw, (confirmed) =>
        if confirmed == true && @confirm_token == true
          tk = _.val(@$("input.token"))
          @current_user.confirm_token tk, (confirmed) =>
            @cb.call(@, confirmed)
            @$el.modal("hide")
        else
          @cb.call(@, confirmed)
          @$el.modal("hide")

    after_render: ->
      @$el.modal("show")
      @$("input#password").focus()
