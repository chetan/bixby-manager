
namespace "Bixby.view", (exports, top) ->

  class exports.TeamRow extends Stark.Partial
    template: "main/_team_row"

    links:
      "a.name":     [ "team_user_view", (el) -> { user: @user } ]
      "a.username": [ "team_user_view", (el) -> { user: @user } ]
      "a.email":    [ "team_user_view", (el) -> { user: @user } ]

    events: null

    after_render: ->
      @stickit(@user)

      # update status
      @$(".status").text(@user.get_status())

      @
