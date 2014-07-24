namespace "Bixby.view", (exports, top) ->

  class exports.ProfileQR extends Stark.View
    el: "div#content"
    template: "main/profile_qr"

    events:
      "click button.2fa": (e) ->
        view = @
        $.ajax "/rest/users/enable_2fa",
          type: "POST",
          data: _.csrf({user_id: @current_user.id}),
          success: (data, textStatus, jqXHR) ->
            view.current_user.set { gauth_enabled: true }
            alert "You have enabled 2-Factor authentication!"
            view.transition("profile")
      "click button.cancel": (e) ->
        @transition("profile")

    after_render: ->
      @$("div.qrcode").qrcode({width: 150, height: 150, text: @current_user.otp()})
