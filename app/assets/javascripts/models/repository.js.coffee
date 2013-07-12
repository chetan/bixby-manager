
namespace 'Bixby.model', (exports, top) ->

  class exports.Repo extends Stark.Model
    urlRoot: "/rest/repos"
    params: [ { name: "repo", set_id: true } ]

    Backprop.create_strings @, "name", "uri", "branch", "public_key"
    Backprop.create @, "requires_key", Boolean

    validation:
      name:
        required: true
      uri:
        required: true
      branch:
        required: false
      requires_key: (val, attr, obj) ->
        if val == true && !(obj.uri && obj.uri.match(/^(git@|git:\/\/|ssh:\/\/)/))
          return "public keys can only be used with git or ssh protocols"
        return null


  class exports.RepoList extends Stark.Collection
    model: exports.Repo
    url: "/rest/repos"

    comparator: (repo) ->
      repo.id
