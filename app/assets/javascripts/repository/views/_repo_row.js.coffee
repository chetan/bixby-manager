
namespace "Bixby.view", (exports, top) ->

  class exports.RepoRow extends Stark.Partial

    template: "repository/_repo_row"

    bindings:
      "#name": "name"
      "#uri": "uri"
      "#branch": "branch"
      "#public_key": "public_key"

    links:
      "a#name": [ "repository_view", (el) -> { repo: @repo } ]

    events:
      "click button.pubkey": (el) ->
        el.preventDefault()
        @$(".modal").modal("show")
        @$("div.modal textarea").focus()

      "focusin div.modal textarea": _.select_text

    after_render: ->
      @stickit(@repo)
      @
