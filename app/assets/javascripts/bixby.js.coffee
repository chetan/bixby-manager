
#= require "./init"

#= require_tree "./helpers"
#= require_tree "./models"

#= require_tree "./main"
#= require_tree "./inventory"
#= require_tree "./monitoring"
#= require_tree "./repository"

# finally, start the app
jQuery ->
  Bixby.app.start()
