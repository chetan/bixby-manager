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
_.eachR = (context, list, func) ->
  @each list, func, context

_.bindR = (context, func, args...) ->
  @bind func, context, args...

# alias away the sync method
Backbone._sync = Backbone.sync

# Add CSRF params to the given hash
_.csrf = (hash) ->
  hash[$("meta[name='csrf-param']").attr('content')] = $("meta[name='csrf-token']").attr('content')
  hash

# define a new sync method which handles Rails CSRF
Backbone.sync = (method, model, success, error) ->
  # only need a token for non-get requests
  if (method == 'create' || method == 'update' || method == 'delete')
    # grab the token from the meta tag rails embeds
    # set it as a model attribute without triggering events
    model.set(_.csrf({}), {silent: true});

  # proxy the call to the old sync method
  return Backbone._sync(method, model, success, error);

# split which handles empty string correctly
_.split = (str, regex) ->
  if ! str
    return []
  return str.split(regex)
