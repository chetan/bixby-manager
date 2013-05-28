
#= require "./init"

#= require_tree "./templates"
#= require_tree "./models"
#= require_tree "./views"
#= require "./states"

#= require_tree "./inventory"
#= require_tree "./monitoring"

# finally, start the app
jQuery ->
  Bixby.app.start()
