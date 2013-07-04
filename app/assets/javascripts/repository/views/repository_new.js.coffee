
namespace "Bixby.view", (exports, top) ->

  class exports.RepositoryNew extends Stark.View
    el: "#content"
    template: "repository/new"

    links: {
      ".add_repo_link": [ "repo_new" ]

    }

