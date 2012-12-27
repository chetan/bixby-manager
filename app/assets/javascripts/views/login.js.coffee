namespace "Bixby.view", (exports, top) ->

  class exports.Login extends Stark.View

    template: "login"
    el: "#body"

    app_events: {
      "state:activate": ->
        $("input.username").putCursorAtEnd();
    }

    events: {
      "blur input.username": (e) ->
        $(e.target).mailcheck({
          suggested: (el, suggestion) ->
            # TODO show alert/notification
            console.log "Did you mean " + suggestion.full + "?"
        })

      "submit form": (e) ->
        e.preventDefault()
        user = $("input.username").val()
        pass = $("input.password").val()

        view = @
        $.ajax("/login", {
          type: "POST",
          data: _.csrf({username: user, password: pass}),
          success: (data, textStatus, jqXHR) ->
            ret = JSON.parse(data)
            view.app.current_user = new Bixby.model.User(ret.user)
            return if ret.redir && view.app.router.route(ret.redir) == true

            # send to default route
            view.app.router.route(view.app.default_route)
          error: (jqXHR, textStatus, errorThrown) ->
            alert("Invalid username or password")
        })

    }

