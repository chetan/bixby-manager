
_bv = Bixby.view

Bixby.app.add_state(
  class extends Stark.State

    name: "login"
    url:  "login"
    tab:  ""

    views:      [ _bv.Login ]

    validate: ->
      # send to home if already logged in
      if Bixby.app.current_user
        @transition "inventory"
        return false
      return true
)

Bixby.app.add_state(
  class extends Stark.State

    name: "profile"
    url:  "profile"

    views:      [ _bv.PageLayout, _bv.Profile ]
)
