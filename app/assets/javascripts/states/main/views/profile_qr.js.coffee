namespace "Bixby.view", (exports, top) ->

  class exports.ProfileQR extends Stark.View
    el: "div#content"
    template: "main/profile_qr"

    events:
      "click button.foobar": ->

    after_render: ->
      @$("div.qrcode").qrcode({width: 150, height: 150, text: @current_user.otp()})
