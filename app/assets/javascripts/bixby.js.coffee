
#= require "./init"

#= require_tree "./helpers"
#= require_tree "./models"
#= require_tree "./states"

# finally, start the app
jQuery ->
  Bixby.app.start()
