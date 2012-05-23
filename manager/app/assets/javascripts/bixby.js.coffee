
#= require "utils"
#= require_tree "./stark"

# setup our namespaces
#= require "bootstrap"

# include all templates
#= require_tree "./templates"

#= require "main_views"

# include all modules
#= require_tree "./inventory"
#= require_tree "./monitoring"

# finally, start the app
jQuery ->
  Bixby.app.start()
