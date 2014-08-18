namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTemplateIndex extends Stark.View
    el: "div.monitoring_content"
    template: "monitoring/check_template_index"

    links:
      ".create_check_template": "mon_check_template_new"
