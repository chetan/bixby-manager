
"use strict"

# Create HTML5 properties on a Model
#
#
# Example usage:
#
# class exports.Host extends Stark.Model
#   @props
#     _strings: ["hostname", "alias", "desc", "ip", "org"]
#     _dates:   ["last_seen_at"]
#     _bools:   ["is_connected"]
#
# @param [Object] new_props         Hash of property types and associated keys
Stark.Model.props = (new_props) ->
  props = (@_props ||= {})
  proto = @prototype
  create_prop = (key) ->
    Object.defineProperty proto, key,
      get: -> @get(key)
      set: (value) -> @set(key, value)

  extract_prop = (keys, f) ->
    keys = [keys] if !_.isArray(keys)
    _.each keys, (k) ->
      create_prop(k)
      props[k] = (s) ->
        # take care to preserve null/undefined/array values, only coerce if we have something
        if s?
          return s if _.isArray(s)
          return f(s)
        else
          return s

  _.each new_props, (val, key) ->
    switch key
      when "_strings"
        extract_prop(val, String)
      when "_dates"
        extract_prop(val, (s) -> moment(s))
      when "_numbers", "_nums", "_integers", "_ints"
        extract_prop(val, Number)
      when "_bools"
        extract_prop(val, Boolean)
      when "_misc", "_other", "_objects", "_object", "_objs", "_obj"
        extract_prop(val, (x) -> return x)


Stark.Model::set = (key, val, options) ->
  if typeof key == 'object'
    attrs = key
    options = val
  else
    (attrs = {})[key] = val

  if props = @constructor._props
    _.each attrs, (v, k) ->
      if props[k]?
        attrs[k] = props[k](v)

  return Stark.Model.__super__.set.call(this, attrs, options)
