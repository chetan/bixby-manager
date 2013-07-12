
namespace 'Bixby.model', (exports, top) ->

  class exports.Repo extends Stark.Model
    urlRoot: ->
      s = "/rest/repos"
      s += "/#{@repo_id}" if @repo_id
      s

    params: [ "repo" ]

    Backprop.create_strings @, "name", "uri", "branch", "public_key"

  class exports.RepoList extends Stark.Collection
    model: exports.Repo
    url: "/rest/repos"

    comparator: (repo) ->
      repo.id
