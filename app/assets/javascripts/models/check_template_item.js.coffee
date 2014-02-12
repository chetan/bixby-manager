
namespace 'Bixby.model', (exports, top) ->

  class exports.CheckTemplateItem extends Stark.Model
    urlRoot: ->
      "/rest/check_templates/#{@check_template_id}/items"

  class exports.CheckTemplateItemList extends Stark.Collection
    model: exports.CheckTemplateItem
    url: -> "/rest/check_templates/#{@check_template_id}/items"
