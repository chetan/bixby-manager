
Bixby.app.add_state(
  class extends Stark.State

    name: "login"
    url:  "login"
    tab:  ""

    views:      [ Bixby.view.Login ]

    validate: ->
      # send to home if already logged in
      if Bixby.app.current_user
        @transition "inventory"
        return false
      return true
)
