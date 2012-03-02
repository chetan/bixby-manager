
jQuery ->
  console.log("starting history engine")
  if (!Backbone.history.start({ pushState: true }))
    console.log("nothing matched, triggering inventory")
    Backbone.history.navigate("inventory")
