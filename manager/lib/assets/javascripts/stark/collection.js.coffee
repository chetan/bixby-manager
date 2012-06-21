
"use strict"

window.Stark or= {}

class Stark.Collection extends Backbone.Collection

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
