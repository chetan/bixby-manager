
class Bixby.Runbooks extends Stark.View

  el: "#content"
  template: "runbooks/runbooks"

  after_render: ->
    @$("select#command").select2({
      allowClear: true
      matcher: (term, text, opt) ->
        # use default matcher to evaluate the option as well its option group label
        optgroup = $(opt).parent().attr("label")
        $.prototype.select2.defaults.matcher(term, text) ||
          $.prototype.select2.defaults.matcher(term, optgroup)
      })

    @$("select#host").select2({
      allowClear: true
      matcher: (term, text, opt) ->
        # use default matcher to evaluate the option as well its option group label
        optgroup = $(opt).parent().attr("label")
        $.prototype.select2.defaults.matcher(term, text) ||
          $.prototype.select2.defaults.matcher(term, optgroup)
      })
