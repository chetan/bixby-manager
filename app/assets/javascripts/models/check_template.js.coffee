
namespace 'Bixby.model', (exports, top) ->

  class exports.CheckTemplate extends Stark.Model
    @key: "check_template"
    urlRoot: ->
      "/rest/check_templates"

    params: [ { name: "check_template", set_id: true } ]

    mode: ->
      @prototype.mode_str @g("mode")

    @mode_str: (val) ->
      switch val
        when "ANY"
          "any tag matches"
        when "ALL"
          "all tags match"
        when "EXCEPT"
          "all or no tags, except the following"

  class exports.CheckTemplateList extends Stark.Collection
    model: exports.CheckTemplate
    @key: "check_templates"
    url: -> "/rest/check_templates"
