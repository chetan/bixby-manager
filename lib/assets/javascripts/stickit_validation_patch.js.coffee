
# Cause Model.validate() to fire when stickit updates a value
#
# adapted from http://jsfiddle.net/fantactuka/6zh5y/
#
#  Minor change to Stickit defaults:
#   - only set() on 'change' event (ignore keyup, paste, cut; will delay firing
#                                   until a blur event)
#   - pass {validate: true} so attribute validated right when view input is
#       synced up with model attribute.
#       {suppress: true} used to set the attribute value even if it does not
#       pass validation so that view inputs are always synced to model
#       attributes whatever value is
_.each Backbone.Stickit._handlers, (handler) ->
  opts = handler.setOptions || {}
  opts.validate = true
  opts.supress  = true
  handler.setOptions = opts
  handler.events = ['change']
