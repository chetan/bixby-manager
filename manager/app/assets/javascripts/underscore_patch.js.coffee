# see https://gist.github.com/2624704 for usage
to_reverse = ['bind', 'delay', 'defer', 'throttle', 'debounce']
mixin = {}
for name in to_reverse then do (name) ->
    mixin["#{name}R"] = (args..., f) -> _(f)[name](args...)
_.mixin mixin

# eachR - allows passing the context as the first param instead of last
Backbone.Collection.prototype.eachR = (context, func) ->
  @each func, context

# eachR - allows passing the context as the first param instead of last
_.eachR = (context, func) ->
  @each func, context
