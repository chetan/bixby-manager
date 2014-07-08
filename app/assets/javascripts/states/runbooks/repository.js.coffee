
#= require_tree "./views"

Bixby.app.add_states { tab: "runbooks", views: [ _bv.PageLayout ] },

  "repository":
    url:    "repository"

    views:      _bv.Repository
    models:     { repos: _bm.RepoList, commands: _bm.CommandList }

  "repository_view":
    url:    "repository/:repo_id"

    views:      _bv.RepoView
    models:     { repo: _bm.Repo, commands: _bm.CommandList }

  "repo_new":
    url:   "repository/new"
    views: _bv.RepoNew
