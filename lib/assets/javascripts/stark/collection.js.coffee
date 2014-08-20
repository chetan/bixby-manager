
#= require "./model_binding"
#= require "./model_util"

"use strict"

window.Stark or= {}

class Stark.Collection extends Backbone.Collection

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "collection"

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

  # Get the classname for this instance
  #
  # @return [String]
  getClassName: ->
    return @constructor.name || /(\w+)\(/.exec(this.constructor.toString())[1]

  # See Backbone.Collection#reset
  #
  # Backbone 1.1 introduced a change to this method. Instead of returning self,
  # it now returns the list of models which were reset. We want the old behavior.
  reset: (args...) ->
    super
    @
