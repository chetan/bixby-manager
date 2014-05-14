
namespace "Bixby.view", (exports, top) ->

  class exports.ForgotPassword extends Stark.View
    el: "div.body"
    template: "main/forgot_password"

    events:
      "keypress #username": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @send_reset()

      "click #reset": (e) ->
        @send_reset()

    send_reset: ->
      user = @$("#username").val()
      if !user
        _.fail("div.valid.username", "username or email is required")
        return

      $.ajax "/users/password",
        type: "POST",
        data: _.csrf({username: user}),
        error: (jqXHR, status, err) ->
          if jqXHR.responseText == "not found"
            _.fail("div.valid.username", "bad username or email")
          else
            _.fail("div.valid.username", "error submitting reset request")

        success: (data, textStatus, jqXHR) ->
          _.pass("div.valid.username")
          $("#success").modal()

    after_render: ->
      super
      @$("#username").focus()



