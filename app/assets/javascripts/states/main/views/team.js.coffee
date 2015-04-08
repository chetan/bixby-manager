
namespace "Bixby.view", (exports, top) ->

  class exports.Team extends Stark.View
    el: "div#content"
    template: "main/team"

    events: null

    links:
      "a.add_user": [ "team_user_new" ]
