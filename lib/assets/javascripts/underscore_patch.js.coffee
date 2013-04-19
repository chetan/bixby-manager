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
  _.each list, func, context

_.bindR = (context, func, args...) ->
  _.bind func, context, args...

# setTimeoutR - allows passing timeout as first param
window.setTimeoutR = (timeout, func) ->
  window.setTimeout(func, timeout)

# alias away the sync method
Backbone._sync = Backbone.sync

# Add CSRF params to the given hash
_.csrf = (hash) ->
  hash[$("meta[name='csrf-param']").attr('content')] = $("meta[name='csrf-token']").attr('content')
  hash

# define a new sync method which handles Rails CSRF
Backbone.sync = (method, model, options) ->
  # only need a token for non-get requests
  if (method == 'create' || method == 'update')
    # grab the token from the meta tag rails embeds
    # set it as a model attribute without triggering events
    model.set(_.csrf({}), {silent: true});

  else if method == 'delete'
    # model is only sent to server on create/update so we need to also add a header for deletes
    options ||= {}
    options.beforeSend = (xhr) ->
      token = _.values(_.csrf({}))[0]
      xhr.setRequestHeader "X-CSRF-Token", token

  # proxy the call to the old sync method
  return Backbone._sync(method, model, options);

# split which handles empty string correctly
_.split = (str, regex) ->
  if ! str
    return []
  return str.split(regex)
