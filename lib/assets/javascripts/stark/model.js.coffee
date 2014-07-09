
#= require "./model_binding"
#= require "./model_util"

"use strict"

window.Stark or= {}

class Stark.Model extends Backbone.Model

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "model"

  _.extend @.prototype, Stark.ModelBinding.prototype
  _.extend @.prototype, Stark.ModelUtil.prototype

  # List of params to extract from the URL (via attributes passed from Router)
  #
  # Can either be an array of parameter names or an array of objects of type:
  # { name: "", set_id: true }
  #
  # @see #extract_param
  params: null

  bound_views: null

  @ajax_methods: {
    POST:   "create"
    PUT:    "update"
    PATCH:  "patch"
    DELETE: "delete"
    GET:    "read"
  }

  initialize: (attributes, options) ->
    super(attributes, options)
    @bound_views = []
    @extract_params(attributes)

  # Proxy for @get(); will return empty string ("") instead of null
  g: (k) ->
    @get(k) || ""

  # Get the classname for this instance
  #
  # @return [String]
  className: ->
    return @constructor.name || /(\w+)\(/.exec(this.constructor.toString())[1]

  ajax: (method, options) ->
    _.extend options, {
      contentType: 'application/json'
      dataType: "json"
      data: JSON.stringify(_.csrf(options.data))
    }

    method = Stark.Model.ajax_methods[method.toUpperCase()] || method
    (@sync || Backbone.sync).call @, method, @, options
