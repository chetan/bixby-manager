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
          @$("form#login_form").submit()

      "focusout #username": (e) ->
        _.mailcheck(e.target)

      "submit form#login_form": (e) ->
        return @login()

    # Check whether or not to show an error message - if we are at the URL /login/fail
    show_error: ->
      return window.location.pathname.match(/login\/fail(\?.*)?$/)

    login: ->
      user = @$("#username").val()
      pass = @$("#password").val()

      if user.length == 0 || (user.length < 6 && user.indexOf("@") >= 0)
        @$("#username").putCursorAtEnd().parent().addClass("has-error")
        return false

      if pass.length == 0
        @$("#password").putCursorAtEnd().parent().addClass("has-error")
        return false

      return true
