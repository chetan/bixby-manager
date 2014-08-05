
namespace "Bixby.view", (exports, top) ->

  class exports.AcceptInvite extends Stark.View
    el: "div.body"
    template: "main/accept_invite"

    events:
      "keypress #password": (e) -> @validate_password(e)
      "keypress #password_confirmation": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @create()
        else
          @validate_password(e)

      "click #create": (e) ->
        @create()

    create: ->
      token = _.param("token")
      pass = @$("#name").val()
      user = @$("#username").val()
      pass = @$("#password").val()
      pass2 = @$("#password_confirmation").val()
      $.ajax "/rest/users/accept_invite",
        type: "POST",
        data: _.csrf({user: {name: name, username: user, password: pass, password_confirmation: pass2, token: token}}),
        error: (jqXHR, status, err) ->
          if ret = JSON.parse(jqXHR.responseText)
            if ret.error
              alert(ret.error) # TODO better error message
              return

            else if ret.errors
              _.each errors, (val, key) ->
                _.fail("div.valid.#{key}", "#{key} #{val[0]}<br/>")
              return

          _.fail("div.valid.password", "error creating account<br/>")

        success: (data, textStatus, jqXHR) ->
          window.location = "/"

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

    after_render: ->
      super
      @$("#name").focus()
