
#= require_tree "./views"

Bixby.app.add_state(
  class extends Stark.State

    name: "login"
    url:  "login"
    tab:  ""

    views:      [ Bixby.view.Login ]
)
