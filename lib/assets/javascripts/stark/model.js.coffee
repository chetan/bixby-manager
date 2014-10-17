
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

  # Map HTTP methods to Backbone.sync methods
  @ajax_methods:
    POST:   "create"
    PUT:    "update"
    PATCH:  "patch"
    DELETE: "delete"
    GET:    "read"

  @ajax_post_methods = [ "post", "put", "patch", "create", "update" ]
  @all_ajax_methods = @ajax_post_methods.concat("delete", "get", "read")

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
  getClassName: ->
    return @constructor.name || /(\w+)\(/.exec(this.constructor.toString())[1]

  # Get the URL for this model, optioally appending the given path
  #
  # @param [String] path
  #
  # @return [String] URL
  url: (path) ->
    url = super()
    if path?
      url += "/" if path[0] != "/" && url[url.length-1] != "/"
      url += path
    return url

  # Send an AJAX request using Backbone.sync
  #
  # @param [String] url
  # @param [String] method            Optional, defaults to POST
  # @param [Object] options           See $.ajax for reference
  ajax: (url, method, options) ->
    if _.isObject(method)
      options = method
      method = "post"

    if _.include(Stark.Model.ajax_post_methods, method.toLowerCase())
      # pass JSON as raw post body
      _.extend options,
        data:        JSON.stringify(_.csrf(options.data))
        contentType: "application/json"

    _.extend options, {url: url, dataType: "json"}

    method = Stark.Model.ajax_methods[method.toUpperCase()] || method
    (@sync || Backbone.sync).call @, method, @, options
