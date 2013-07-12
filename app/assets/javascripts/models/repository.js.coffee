
namespace 'Bixby.model', (exports, top) ->

  class exports.Repo extends Stark.Model
    urlRoot: "/rest/repos"
    params: [ { name: "repo", set_id: true } ]

    Backprop.create_strings @, "name", "uri", "branch", "public_key"
    Backprop.create @, "requires_key", Boolean

  class exports.RepoList extends Stark.Collection
    model: exports.Repo
    url: "/rest/repos"

    comparator: (repo) ->
      repo.id
