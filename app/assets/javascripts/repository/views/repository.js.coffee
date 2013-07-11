
namespace "Bixby.view", (exports, top) ->

  class exports.Repository extends Stark.View
    el: "#content"
    template: "repository/home"

    links:
      ".add_repo_link": [ "repo_new" ]

  class exports.RepoRow extends Stark.Partial

    template: "repository/_repo_row"

    links:
      "a.repo": [ "repository_view", (el) -> { repo: @repo } ]

    events:
      "click button.pubkey": (el) ->
        el.preventDefault()
        @$(".modal").modal("show")
        @$("div.modal textarea").focus()

      "focusin div.modal textarea": _.select_text

  class exports.CommandTable extends Stark.Partial
    template: "repository/_command_table"
