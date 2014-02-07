
"use strict"

window.Stark or= {}

class Stark.Logger

  @enabled: true
  logger: ""

  # write messages at various log levels

  # method generator
  create_logger = (level) ->
    return (msgs...) ->
      return if !Stark.Logger.enabled
      console[level] "[#{@logger}]", msgs...

  # create methods for each log level
  @.prototype[level] = create_logger(level) for level in [ "log", "debug", "info", "warn", "error" ]

  # wrapper around groups
  begin_group: (args...) ->
    if console.group? && Stark.Logger.enabled
      console.group(args...)

  end_group: ->
    if console.group? && Stark.Logger.enabled
      console.groupEnd()

  # wrapper around timers
  start_timer: (name) ->
    if console.time? && Stark.Logger.enabled
      console.time(name)

  stop_timer: (name) ->
    if console.time? && Stark.Logger.enabled
      console.timeEnd(name)
