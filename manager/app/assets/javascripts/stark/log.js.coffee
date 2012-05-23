
"use strict"

window.Stark or= {}

class Stark.Logger

  @enabled: true
  logger: ""

  log: (msgs...) ->
    if !Stark.Logger.enabled
      return
    console.log "[#{@logger}]", msgs...
