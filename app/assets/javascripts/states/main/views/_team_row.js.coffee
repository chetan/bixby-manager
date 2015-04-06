
namespace "Bixby.view", (exports, top) ->

  class exports.TeamRow extends Stark.Partial
    template: "main/_team_row"

    links:
      "a.name":     [ "team_user_view", (el) -> { user: @user } ]
      "a.username": [ "team_user_view", (el) -> { user: @user } ]

    events: null

    after_render: ->
      @stickit(@user)

      # update status
      status = if @user.last_sign_in_at
        "Active"
      else if @user.invite_created_at && !@user.invite_accepted_at
        "Invite Pending"
      else
        "Never logged in"
      @$(".status").text(status)

      @
