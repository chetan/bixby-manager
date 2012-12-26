namespace "Bixby.view", (exports, top) ->

  class exports.Login extends Stark.View

    template: "login"
    el: "#body"

    app_events: {
      "state:activate": ->
        $("input.username").putCursorAtEnd();
    }

    events: {
      "submit form": (e) ->
        e.preventDefault()

        # TODO implement mailcheck.js on username

        user = $("input.username").val()
        pass = $("input.password").val()

        view = @
        $.ajax("/login", {
          type: "POST",
          data: _.csrf({username: user, password: pass}),
          success: (data, textStatus, jqXHR) ->
            view.transition "inventory"
          error: (jqXHR, textStatus, errorThrown) ->
            # display error
            alert("error logging in")
        })

    }

