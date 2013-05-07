# see https://gist.github.com/2624704 for usage
to_reverse = ['bind', 'delay', 'defer', 'throttle', 'debounce']
mixin = {}
for name in to_reverse then do (name) ->
    mixin["#{name}R"] = (args..., f) -> _(f)[name](args...)
_.mixin mixin

# eachR - allows passing the context as the first param instead of last
_.eachR = (context, list, func) ->
  _.each list, func, context

_.mapR = (context, list, func) ->
  _.map list, func, context

_.bindR = (context, func, args...) ->
  _.bind func, context, args...

# setTimeoutR - allows passing timeout as first param
window.setTimeoutR = (timeout, func) ->
  window.setTimeout(func, timeout)

# split which handles empty string correctly
_.split = (str, regex) ->
  if ! str
    return []
  return str.split(regex)

# Check whether the given element is in the current viewport
#
# via: http://stackoverflow.com/questions/487073/check-if-element-is-visible-after-scrolling#488073
_.isScrolledIntoView = (el) ->
  docViewTop = $(window).scrollTop()
  docViewBottom = docViewTop + $(window).height()

  elTop = $(el).offset().top
  elBottom = elTop + $(el).height()

  return ((elBottom <= docViewBottom) && (elTop >= docViewTop))
