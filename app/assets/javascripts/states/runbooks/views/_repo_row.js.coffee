
namespace "Bixby.view", (exports, top) ->

  class exports.RepoRow extends Stark.Partial

    template: "runbooks/_repository_row"

    bindings:
      "#name": "name"
      "#uri": "uri"
      "#branch": "branch"
      "#public_key": "public_key"
      "#updated_at":
        observe: "updated_at"
        onGet: (val, opts) ->
          if val
            moment(val).format("MMM/DD/YYYY HH:mm:ss", new Date(val))
          else
            "never"

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
