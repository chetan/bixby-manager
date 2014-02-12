
namespace 'Bixby.model', (exports, top) ->

  class exports.CheckTemplate extends Stark.Model
    urlRoot: ->
      "/rest/check_templates"

  class exports.CheckTemplateList extends Stark.Collection
    model: exports.CheckTemplate
    url: -> "/rest/check_templates"
