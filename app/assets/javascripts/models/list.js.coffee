
namespace 'Bixby.model', (exports, top) ->

  class exports.List

    # mixin logger
    _.extend @.prototype, Stark.Logger.prototype
    logger: "model"

    url: null
    data: null

    # Get the classname for this instance
    #
    # @return [String]
    getClassName: ->
      return @constructor.name || /(\w+)\(/.exec(this.constructor.toString())[1]

    get: ->
      @data

    reset: (data) ->
      @data = data
      @

    fetch: (opts) ->
      model = @
      $.ajax({
        type: "GET"
        url: @url
        dataType: "json"
        success: (data, status, xhr) ->
          model.data = data
          opts.success(model, data)
        error: (xhr, status, error) ->
          opts.error(model, error)
      })


  class exports.HostTagList extends exports.List
    url: "/rest/hosts/tags"
