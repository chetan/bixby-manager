
namespace "Bixby.view", (exports, top) ->

  class exports.ResetPassword extends Stark.View
    el: "div.body"
    template: "main/reset_password"

    events:
      "click #reset": (e) ->
        token = _.param("reset_password_token")
        pass = @$("#password").val()
        pass2 = @$("#password_confirmation").val()
        $.ajax "/users/password",
          type: "PUT",
          data: _.csrf({user: {password: pass, password_confirmation: pass2, reset_password_token: token}}),
          error: (jqXHR, status, err) ->
            console.log "caught error"
            console.log status
            console.log err
            if err == "not found"
              console.log "user wasn't found"

          success: (data, textStatus, jqXHR) ->
            window.location = "/"

    after_render: ->
      super
      @$("#password").focus()
