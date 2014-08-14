namespace "Bixby.view", (exports, top) ->

  class exports.LoginToken extends Stark.View

    template: "main/login_token"
    el: "div.body"
    focus: "input.token"

    events:
      "keypress input": (e) ->
        if e.keyCode == 13
          e.preventDefault()
          @check()

      "click button.check_token": (e) ->
        @check()

    check: ->
      token = @$("#token").val()
      $.ajax "/login/verify_token",
        type: "POST",
        data: _.csrf({user: {token: token}}),
        success: (data, textStatus, jqXHR) ->
          ret = JSON.parse(data)

          # update csrf token
          $("meta[name='csrf-token']").attr('content', ret.csrf)

          Bixby.app.bootstrap_data.users = new Bixby.model.UserList().reset(ret.users)
          Bixby.app.current_user = new Bixby.model.User(ret.user)

          if ret.redir && Bixby.app.router.route(ret.redir) == true
            return

          if Bixby.app.redir
            r = Bixby.app.redir
            Bixby.app.redir = null
            return Bixby.app.transition r[0], r[1]

          # send to default route
          Bixby.app.router.route(Bixby.app.default_route)

        error: (xhr, textStatus, errorThrown) ->
          data = JSON.parse(xhr.responseText)
          if data.error.match(/Login failed/)
            alert("Invalid token. Try again")
          else if data.error.match(/Invalid session/)
            Bixby.app.transition("login_fail", {reason: "Session timed out. Please login again"})
