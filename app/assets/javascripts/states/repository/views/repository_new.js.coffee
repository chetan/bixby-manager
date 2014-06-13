
namespace "Bixby.view", (exports, top) ->

  class exports.RepoNew extends Stark.View
    el: "#content"
    template: "repository/new"

    bindings:
      "#name": "name"
      "#uri": "uri"
      "#branch": "branch"
      "#requires_key": "requires_key"

    links:
      ".add_repo_link": "repo_new"

    events:
      "click button.submit": (e) ->
        e.preventDefault()

        @repo.validate()
        return if ! @repo.isValid()

        v = @
        @repo.save null, success: -> v.transition("repository")

    after_render: ->
      @repo = new Bixby.model.Repo()
      @stickit(@repo)
      @
