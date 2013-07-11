
namespace "Bixby.view", (exports, top) ->

  class exports.RepoNew extends Stark.View
    el: "#content"
    template: "repository/new"

    links:
      ".add_repo_link": [ "repo_new" ]

    events:
      "click button.submit": (e) ->
        e.preventDefault()

        attrs = @get_attributes("name", "uri", "branch", "requires_key")

        if attrs["requires_key"] == true
          # validate a git proto link
          if !attrs["uri"].match(/^(git@|git:\/\/|ssh:\/\/)/)
            _.fail @$("span.valid.uri").html(_.icon("remove") + " public keys can only be used with git or ssh protocols")
            return
          else
            _.pass @$("span.valid.uri")

        v = @
        repo = new Bixby.model.Repo()
        repo.save attrs, success: -> v.transition("repository")

