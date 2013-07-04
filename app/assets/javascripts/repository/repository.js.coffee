
#= require_tree "./views"

_bv = Bixby.view
_bm = Bixby.model

Bixby.app.add_state(
  class extends Stark.State
    name:   "repository"
    url:    "repository"
    tab:    "repository"

    views:      [ _bv.PageLayout, _bv.Repository ]
    models:     { repos: _bm.RepoList }
)

Bixby.app.add_state(
  class extends Stark.State
    name:   "repo_new"
    url:    "repository/new"
    tab:    "repository"

    views:      [ _bv.PageLayout, _bv.RepositoryNew ]
)
