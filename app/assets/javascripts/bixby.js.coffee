
#= require "./init"

#= require_tree "./templates"
#= require_tree "./models"
#= require_tree "./views"

#= require_tree "./inventory"
#= require_tree "./monitoring"

#= require "./login"

# finally, start the app
jQuery ->
  Bixby.app.start()
