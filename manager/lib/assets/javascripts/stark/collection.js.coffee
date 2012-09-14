
"use strict"

window.Stark or= {}

class Stark.Collection extends Backbone.Collection

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "collection"

  # mixin model binding
  _.extend @.prototype, Stark.ModelBinding.prototype

  bound_views: null

  initialize: (attributes, options) ->
    super(attributes, options)
    bound_views = []

  extract_param: (data, name) ->
    if ! _.isObject(data)
      return false

    id = "#{name}_id"
    if data.params? && data.params[id]?
      @[id] = data.params[id]
    else if data[name]?
      @[id] = data[name].id
    else
      return false

    return true
