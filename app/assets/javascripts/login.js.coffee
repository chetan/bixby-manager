
jQuery ->
  _bv = Bixby.view

  Bixby.app.add_state(
    class extends Stark.State

      name: "login"
      url:  "login"
      tab:  ""

      views:      [ _bv.PageLayout, _bv.Login ]
  )
