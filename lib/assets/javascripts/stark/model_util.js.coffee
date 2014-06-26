
"use strict"

window.Stark or= {}

class Stark.ModelUtil

  # Extract all params as defined in @params
  extract_params: (attributes) ->
    _.eachR @, @params, (obj) ->
      if _.isObject(obj)
        @extract_param(attributes, obj.name, obj.set_id)
      else
        @extract_param(attributes, obj)

  # Look for the given paramter name in the data hash
  #
  # NOTE: Actually searches for #{name}_id
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

    # search for id
    if data.params? && data.params[id]?
      @[id] = data.params[id]
    else if data[name]? && _.isObject(data[name]) && data[name].id?
      @[id] = data[name].id
    else if data[id]?
      @[id] = data[id]
    else
      return false

    if set_id
      @id = @[id]
      # need to set() as well due to a change in backbone 1.1.1 (isNew() now relies on has("id"))
      # this is probably more correct anyway
      @set {id: @id}

    return true
