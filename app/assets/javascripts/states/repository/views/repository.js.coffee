
namespace "Bixby.view", (exports, top) ->

  class exports.Repository extends Stark.View
    el: "#content"
    template: "repository/home"

    links:
      ".add_repo_link": "repo_new"
