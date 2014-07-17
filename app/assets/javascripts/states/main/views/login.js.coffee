namespace "Bixby.view", (exports, top) ->

  class exports.Login extends Stark.View

    template: "main/login"
    el: "div.body"

    links:
      "a#forgot": "forgot"

    app_events:
      "state:activate": ->
        $("#username").putCursorAtEnd()

    events:
      "keypress input": (e) ->
        if @$("#username").val().length > 6
          @$("#username").parent().removeClass("has-error")

        if @$("#password").val().length > 0
          @$("#password").parent().removeClass("has-error")

        if e.keyCode == 13
          e.preventDefault()
          @login()

      "focusout #username": (e) ->
        _.mailcheck(e.target)

      "click button.login": (e) ->
        @login()

    login: ->
      user = @$("#username").val()
      pass = @$("#password").val()

      if user.length == 0 || (user.length < 6 && user.indexOf("@") >= 0)
        @$("#username").putCursorAtEnd().parent().addClass("has-error")
        return

      if pass.length == 0
        @$("#password").putCursorAtEnd().parent().addClass("has-error")
        return

      view = @
      $.ajax "/login",
        type: "POST",
        data: _.csrf({user: {username: user, password: pass}}),
        success: (data, textStatus, jqXHR) ->
          ret = JSON.parse(data)

          if ret.tmpid
            alert ret.tmpid
            return view.app.transition "checkga", {tmpid: ret.tmpid}

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
