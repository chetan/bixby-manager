
namespace "Bixby.view", (exports, top) ->

  class exports.RepoNew extends Stark.View
    el: "#content"
    template: "repository/new"

    links: {
      ".add_repo_link": [ "repo_new" ]

    }

