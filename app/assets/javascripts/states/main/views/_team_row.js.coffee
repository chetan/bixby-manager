
namespace "Bixby.view", (exports, top) ->

  class exports.TeamRow extends Stark.Partial
    template: "main/_team_row"
    bindings:
      ".name":  "name"
      ".username":  "username"
      ".email": "email"
      ".phone": "phone"

    events: null

    after_render: ->
      @stickit(@user)
      @
