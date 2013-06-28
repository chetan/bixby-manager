namespace "Bixby.view", (exports, top) ->

  class exports.Spinner extends Stark.View
    opts:
      lines: 12
      length: 7
      width: 4
      radius: 10
      color: '#000'
      speed: 1
      trail: 60
      shadow: false
      hwaccel: false
      className: 'spinner'
      zIndex: 2e9
      top: '0'
      left: '0'

    initialize: (target, opts) ->
      super

      if _.isArray(target)
        target = target[0]

      if opts?
        _.eachR @, _.keys(opts), (key) ->
          @opts[key] = opts[key]

      @target = $(target)
      @render(@target)

    render: (target) ->
      @target = $(target)
      @spinner = new window.Spinner(@opts).spin()
      @target.append(@spinner.el)

    stop: ->
      @spinner.stop()
      @target.height("auto")
