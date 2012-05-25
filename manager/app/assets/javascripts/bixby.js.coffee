
#= require "stark/utils"
#= require "stark/log"
#= require_tree "./stark"

# include all templates, models
#= require_tree "./templates"
#= require_tree "./models"

#= require "main_views"

# include all modules
#= require_tree "./inventory"
#= require_tree "./monitoring"

# finally, start the app
app = new Stark.App()
app.template_root = "templates/"
app.default_route = "inventory"
Bixby.app = app

jQuery ->
  Bixby.app.start()
