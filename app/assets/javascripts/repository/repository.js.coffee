
#= require_tree "./views"

_bv = Bixby.view
_bvr = _bv.repository
_bm = Bixby.model

Bixby.app.add_state(
  class extends Stark.State
    name:   "repository"
    url:    "repository"
    tab:    "repository"

    views:      [ _bv.PageLayout, _bvr.Repository ]
    models:     { repos: _bm.RepoList }
)
