
#= require "./init"
#= require "./login"

#= require_tree "./templates"
#= require_tree "./models"
#= require_tree "./views"

#= require_tree "./inventory"
#= require_tree "./monitoring"

# finally, start the app
jQuery ->
  Bixby.app.start()
