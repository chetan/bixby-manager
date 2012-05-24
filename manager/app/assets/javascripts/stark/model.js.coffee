
"use strict"

window.Stark or= {}

class Stark.Model extends Backbone.Model

  extract_param: (data, name) ->

    id = "#{name}_id"

    if ! _.isObject(data)
      if _.isNumber(data)
        @[id] = data
        return true

      return false

    if data.params? && data.params[id]?
      @[id] = data.params[id]
    else if data[name]?
      @[id] = data[name].id
    else
      return false

    return true
