
#= require_tree "./views"

_bv = Bixby.view
_bm = Bixby.model

Bixby.app.add_state(
  class extends Stark.State
    name:   "repository"
    url:    "repository"
    tab:    "repository"

    views:      [ _bv.PageLayout, _bv.Repository ]
    models:     { repos: _bm.RepoList, commands: _bm.CommandList }
)

Bixby.app.add_state(
  class extends Stark.State
    name:   "repository_view"
    url:    "repository/:repo_id"
    tab:    "repository"

    views:      [ _bv.PageLayout, _bv.RepoView ]
    models:     { repo: _bm.Repo, commands: _bm.CommandList }
)

Bixby.app.add_state(
  class extends Stark.State
    name:   "repo_new"
    url:    "repository/new"
    tab:    "repository"

    views:      [ _bv.PageLayout, _bv.RepoNew ]
)
