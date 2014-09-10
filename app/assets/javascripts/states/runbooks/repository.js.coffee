
#= require_tree "./views"

help =
  repositories: "Repositories are simply Git or Subversion repositories containing scripts which can be run on servers.\n\nThe default `vendor` repository implements all of the core Bixby functionality, including monitoring and inventory management.\n\nHere you can add your own repositories containing custom monitoring plugins or other scripts."

Bixby.app.add_states { tab: "runbooks", views: [ _bv.PageLayout ] },

  "repository":
    url:    "repository"
    help:   help.repositories

    views:      _bv.Repository
    models:     { repos: _bm.RepoList, commands: _bm.CommandList }

  "repository_view":
    url:    "repository/:repo_id"
    help:   help.repositories

    views:      _bv.RepoView
    models:     { repo: _bm.Repo, commands: _bm.CommandList }

  "repo_new":
    url:   "repository/new"
    help:   "Use this form to add a new Git or Subversion repository. Once added, you can run any script in the repository on your servers."
    views: _bv.RepoNew
