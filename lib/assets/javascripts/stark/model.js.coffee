
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

  initialize: (attributes, options) ->
    super(attributes, options)
    @bound_views = []
    @extract_params(attributes)

  # Proxy for @get(); will return empty string ("") instead of null
  g: (k) ->
    @get(k) || ""
