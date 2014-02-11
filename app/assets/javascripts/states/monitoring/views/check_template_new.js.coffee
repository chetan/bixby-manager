
namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTemplateNew extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/check_template_new"

    events: {
    }

    after_render: ->
      @$("input.tags").select2({
        tags: @tags.get()
        tokenSeparators: [",", " "]
      })
