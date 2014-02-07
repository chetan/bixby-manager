
# Create namespaces for your code
#
# # namespace Usage:
# #
# namespace 'Hello.World', (exports) ->
#   # `exports` is where you attach namespace members
#   exports.hi = -> console.log 'Hi World!'

# namespace 'Say.Hello', (exports, top) ->
#   # `top` is a reference to the main namespace
#   exports.fn = -> top.Hello.World.hi()

# Say.Hello.fn()  # prints 'Hi World!'

window.namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top


# Helper function for calling fetch() on multiple models/collections and then
# calling a callback when all have completed (or there was an error)
#
# Callback is of form: function(err, results)
# Where:
#   err = response object from fetch error, or NULL if no error
#   results = models/collections that were fetched
Backbone.multi_fetch = (models, callback) ->
  if ! _.isArray(models)
    models = [ models ]

  tasks = _.map models, (model) ->
    # call fetch on each model, passing callbacks for success/error
    # see Backbone Model#fetch or Collection#fetch
    (cb) -> model.fetch({
      success:  (m, r) -> cb(null, m),  # collect the model
      error:    (m, r) -> cb(r, m)      # collect the response and model
    })

  async.parallel(tasks, callback)


# Helper function for calling save() on multiple models/collections and then
# calling a callback when all have completed (or there was an error)
#
# Callback is of form: function(err, results)
# Where:
#   err = response object from fetch error, or NULL if no error
#   results = models/collections that were fetched
Backbone.multi_save = (models, callback) ->
  if ! _.isArray(models)
    models = [ models ]

  tasks = _.map models, (model) ->
    # call save on each model, passing callbacks for success/error
    # see Backbone Model#save or Collection#save
    (cb) -> model.save({}, {
      success:  (m, r) -> cb(null, m),  # collect the model
      error:    (m, r) -> cb(r, m)      # collect the response and model
    })

  async.parallel(tasks, callback)
