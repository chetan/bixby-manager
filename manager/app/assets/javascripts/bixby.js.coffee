
#= require_tree "./templates"
#= require_tree "./models"
#= require_tree "./views"

#= require_tree "./inventory"
#= require_tree "./monitoring"

# finally, start the app
app = new Stark.App()
app.default_route = "inventory"
Bixby.app = app

jQuery ->
  Bixby.app.start()
