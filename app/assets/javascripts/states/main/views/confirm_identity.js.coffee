namespace "Bixby.view", (exports, top) ->

  class exports.ConfirmIdentity extends Stark.View

    tagName:   "div"
    className: "modal confirm"
    template:  "main/confirm_identity"
    confirm_password: true
    confirm_token: false
    reason_for_prompt: "As a precaution, users must verify their identity before they are allowed to perform potentially dangerous actions"

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
      if @confirm_password == true
        pw = _.val(@$("input.password"))
        @current_user.confirm_password pw, (confirmed) =>
          if confirmed == true && @confirm_token == true
            @confirm_token_optional()
          else
            @cb.call(@, confirmed)
            @$el.modal("hide")

      if (@confirm_token == true && @confirm_password == false)
        @confirm_token_optional()

    confirm_token_optional: ->
          tk = _.val(@$("input.token"))
          @current_user.confirm_token tk, (confirmed) =>
            @cb.call(@, confirmed)
            @$el.modal("hide")

    after_render: ->
      @$el.modal("show")
      if @$("input#password").length
        @$("input#password").focus()
      else
        @$("input#token").focus()
