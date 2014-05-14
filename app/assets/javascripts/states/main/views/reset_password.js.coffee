
namespace "Bixby.view", (exports, top) ->

  class exports.ResetPassword extends Stark.View
    el: "div.body"
    template: "main/reset_password"

    events:
      "keypress #password_confirmation": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @reset_password()

      "click #reset": (e) ->
        @reset_password()

    reset_password: ->
      token = _.param("reset_password_token")
      pass = @$("#password").val()
      pass2 = @$("#password_confirmation").val()
      $.ajax "/users/password",
        type: "PUT",
        data: _.csrf({user: {password: pass, password_confirmation: pass2, reset_password_token: token}}),
        error: (jqXHR, status, err) ->
          if ret = JSON.parse(jqXHR.responseText)
            errors = ret.errors
            if errors
              _.each errors, (val, key) ->
                _.fail("div.valid.#{key}", "#{key} #{val[0]}<br/>")
              return

          _.fail("div.valid.password", "error resetting password<br/>")

        success: (data, textStatus, jqXHR) ->
          window.location = "/"

    after_render: ->
      super
      @$("#password").focus()
