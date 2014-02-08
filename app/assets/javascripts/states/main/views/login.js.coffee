namespace "Bixby.view", (exports, top) ->

  class exports.Login extends Stark.View

    template: "main/login"
    el: "#body"

    app_events: {
      "state:activate": ->
        $("input.username").putCursorAtEnd()
    }

    events: {
      "blur input.username": (e) ->
        _.mailcheck(e.target)

      "submit form": (e) ->
        e.preventDefault()
        user = $("input.username").val()
        pass = $("input.password").val()

        view = @
        $.ajax("/login", {
          type: "POST",
          data: _.csrf({user: {username: user, password: pass}}),
          success: (data, textStatus, jqXHR) ->
            ret = JSON.parse(data)

            # update csrf token
            $("meta[name='csrf-token']").attr('content', ret.csrf)

            Bixby.app.bootstrap_data.users = new Bixby.model.UserList().reset(ret.users)
            view.app.current_user = new Bixby.model.User(ret.user)

            if ret.redir && view.app.router.route(ret.redir) == true
              return

            if view.app.redir
              r = view.app.redir
              view.app.redir = null
              return view.app.transition r[0], r[1]

            # send to default route
            view.app.router.route(view.app.default_route)

          error: (jqXHR, textStatus, errorThrown) ->
            alert("Invalid username or password")
        })

    }

