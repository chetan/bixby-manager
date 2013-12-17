namespace "Bixby.view", (exports, top) ->

  class exports.Spinner extends Stark.View

    default_opts:
      lines:     12,        # The number of lines to draw
      length:    7,         # The length of each line
      width:     4,         # The line thickness
      radius:    30,        # The radius of the inner circle
      corners:   1,         # Corner roundness (0..1)
      rotate:    0,         # The rotation offset
      direction: 1,         # 1: clockwise, -1: counterclockwise
      color:     '#000',    # #rgb or #rrggbb or array of colors
      speed:     1,         # Rounds per second
      trail:     60,        # Afterglow percentage
      shadow:    false,     # Whether to render a shadow
      hwaccel:   false,     # Whether to use hardware acceleration
      className: 'spinner', # The CSS class to assign to the spinner
      zIndex:    2e9,       # The z-index (defaults to 2000000000)
      top:       '0',       # Top position relative to parent in px
      left:      '0'        # Left position relative to parent in px

    initialize: (target, opts) ->
      super(null) # don't pass args

      if _.isArray(target)
        target = target[0]
      @target = $(target)

      @opts = _.extend({}, @default_opts, opts)
      @render()

    render: (target) ->
      if target?
        @target = $(target)
      @spinner = new window.Spinner(@opts)
      @start()
      @

    start: ->
      @spinner.spin()
      $(@spinner.el).css({top: @opts.top, left: @opts.left})
      @target.append(@spinner.el)

    stop: ->
      @spinner.stop()
      # @target.height("auto")
