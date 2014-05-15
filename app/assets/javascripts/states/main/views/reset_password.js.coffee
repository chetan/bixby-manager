
namespace "Bixby.view", (exports, top) ->

  class exports.ResetPassword extends Stark.View
    el: "div.body"
    template: "main/reset_password"

    events:
      "keypress #password": (e) -> @validate_password(e)
      "keypress #password_confirmation": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @reset_password()
        else
          @validate_password(e)

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

    validate_password: _.debounceR 100, (e) ->
      div1 = "div.valid.password"
      div2 = "div.valid.password_confirmation"
      p = @$("#password").val()
      pc = @$("#password_confirmation").val()
      if p && p.length > 0
        if p.length < 8
          _.fail div1
          _.fail div2, 'must be at least 8 characters'
        else if p != pc
          _.fail div1
          _.fail div2, 'passwords must match'
        else
          _.pass div1
          _.pass div2
      else
        _.clear_valid_input(div1)
        _.clear_valid_input(div2)
