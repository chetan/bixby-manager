
namespace "Bixby.view", (exports, top) ->

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
