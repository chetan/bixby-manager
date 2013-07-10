
namespace "Bixby.view", (exports, top) ->

  class exports.Repository extends Stark.View
    el: "#content"
    template: "repository/home"

    links: {
      ".add_repo_link": [ "repo_new" ]

    }

  class exports.RepoRow extends Stark.Partial

    template: "repository/_repo_row"

    links: {
      "a.repo": [ "repository_view", (el) -> { repo: @repo } ]
    }

  class exports.CommandTable extends Stark.Partial
    template: "repository/_command_table"
