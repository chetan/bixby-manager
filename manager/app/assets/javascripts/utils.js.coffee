
# Helper function for calling fetch() on multiple models/collections and then
# calling a callback when all have completed (or there was an error)
#
# Callback is of form: function(err, results)
# Where:
#   err = response object from fetch error, or NULL if no error
#   results = models/collections that were fetched
Backbone.multi_fetch = (fetches, callback) ->
  if ! _.isArray(fetches)
    fetches = [ fetches ]

  tasks = _.map fetches, (f) ->
    (cb) -> f.fetch({
        success: (m, r) -> cb(null, m), # if success, collect the model
        error: (m, r) -> cb(r, m) # if error, collect the response, then the model
      })

  async.parallel(tasks, callback)

# Helper function for calling save() on multiple models/collections and then
# calling a callback when all have completed (or there was an error)
#
# Callback is of form: function(err, results)
# Where:
#   err = response object from fetch error, or NULL if no error
#   results = models/collections that were fetched
Backbone.multi_save = (saves, callback) ->
  if ! _.isArray(saves)
    saves = [ saves ]

  tasks = _.map saves, (f) ->
    (cb) -> f.save({}, {
        success: (m, r) -> cb(null, m)  # if success, collect the model
        error: (m, r) -> cb(r, m)       # if error, collect the response, then the model
      })
  async.parallel(tasks, callback)
