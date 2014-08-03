namespace "Bixby.view", (exports, top) ->

  class exports.LoginToken extends Stark.View

    template: "main/login_token"
    el: "div.body"


    events:
      "click button.check_token": (e) ->
        @check()

    check: ->
      token = @$("#token").val()

      view = @
      $.ajax "/login/verify_token",
        type: "POST",
        data: _.csrf({user: {token: token}}),
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
