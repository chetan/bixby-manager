namespace "Bixby.view", (exports, top) ->

  class exports.CheckGa extends Stark.View

    template: "main/check_ga"
    el: "div.body"


    events:
      "click button.check_token": (e) ->
        @check()

    check: ->
      gauth_token = @$("#gauth_token").val()
      $.ajax "/login/checkga",
        type: "POST",
        data: _.csrf({user: {tmpid: @tmpid, gauth_token: gauth_token}}),
