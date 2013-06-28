
#= require "./init"

#= require_tree "./models"

#= require_tree "./main"
#= require_tree "./inventory"
#= require_tree "./monitoring"

# finally, start the app
jQuery ->
  Bixby.app.start()
