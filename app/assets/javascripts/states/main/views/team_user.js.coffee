
namespace "Bixby.view", (exports, top) ->

  class exports.TeamUser extends Stark.View
    el: "div#content"
    template: "main/team_user"

    events:
      "click .btn-edit": (e) ->
        @transition("team_user_edit", {user: @user})
