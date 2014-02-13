
namespace 'Bixby.model', (exports, top) ->

  class exports.CheckTemplate extends Stark.Model
    urlRoot: ->
      "/rest/check_templates"

    params: [ { name: "check_template", set_id: true } ]

    mode: ->
      switch @g("mode")
        when "ANY"
          "any tag matches"
        when "ALL"
          "all tags match"
        when "EXCEPT"
          "all or no tags, except the following"

  class exports.CheckTemplateList extends Stark.Collection
    model: exports.CheckTemplate
    url: -> "/rest/check_templates"
