namespace "Bixby", (exports, top) ->

  class exports.DateTimePicker extends Stark.Partial
    className: "date_time_picker"
    template: "main/_date_time_picker"

    ui:
      calendar: "button.calendar"
      natural:
        text: "input.natural"

    events:
      "click calendar": (e) ->
        e.stopPropagation()
        e.preventDefault()
        @ui.calendar.datepicker("show")

      "keyup natural.text": _.debounceR 250, (e) ->
        _.unique_val e.target, (val) => @validate_schedule(val)

    validate_schedule: (val) ->
      div = "div.valid.natural"
      if !(val && val.length)
        # clear the validation
        @ui.natural.text.trigger("datepicker.change", false)
        return _.clear_valid_input(div)

      Bixby.model.ScheduledCommand.validate "natural", val, (res) =>
        args = if res != false
          res # [time, time_rel]
        else
          []
        args.unshift(res != false)
        @ui.natural.text.trigger("datepicker.change", args)

    validate_datepicker: (date, time) ->
      date ?= new Date()
      date = moment(date)

      if !time
        @ui.natural.text.val("time is required").trigger("datepicker.change", false)
        return

      Bixby.model.ScheduledCommand.validate "natural", time, true, (res) =>
        if res == false
          return @ui.natural.text.val("invalid time: " + time).trigger("datepicker.change", false)

        # combine date & time
        time = moment(res[0])
        date = moment(new Date(date.year(), date.month(), date.date(), time.hours(), time.minutes(), time.seconds()))
        if (new Date() - date._d) > 0
          return @ui.natural.text.val("date/time is in the past").trigger("datepicker.change", false)
        @ui.natural.text.val(date.format("L HH:mm:ss")).trigger("datepicker.change", [true, date])


    after_render: ->

      @ui.calendar.datepicker(
        keyboardNavigation: true
        todayHighlight: true
        startDate: new Date()
        ).on "hide", (e) =>
          @validate_datepicker(e.date, e.time)
