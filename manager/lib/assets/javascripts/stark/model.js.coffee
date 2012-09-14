
"use strict"

window.Stark or= {}

class Stark.Model extends Backbone.Model

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "model"

  # mixin model binding
  _.extend @.prototype, Stark.ModelBinding.prototype

  bound_views: null

  initialize: (attributes, options) ->
    super(attributes, options)
    bound_views = []

  # look for the given paramter name in the data hash
  # actually searches for name_id
  #
  # @param [Object] data
  # @param [String] name        parameter name to extract (_id will be appended)
  # @param [Boolean] set_id     If true, the extracted param will set in @id as well as @name_id
  #
  # @return [Boolean] returns true if the paramter was found
  extract_param: (data, name, set_id) ->

    id = "#{name}_id"

    # see if an integer id was passed directly
    if ! _.isObject(data)
      if _.isNumber(data)
        @[id] = data
        @id = data if set_id
        return true

      return false

    # search data.params hash
    if data.params? && data.params[id]?
      @[id] = data.params[id]
    else if data[name]?
      @[id] = data[name].id
    else
      return false

    @id = @[id] if set_id
    return true

  # Proxy for @get(); will return empty string ("") instead of null
  g: (k) ->
    @get(k) || ""
