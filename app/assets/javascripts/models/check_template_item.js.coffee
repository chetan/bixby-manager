
namespace 'Bixby.model', (exports, top) ->

  class exports.CheckTemplateItem extends Stark.Model
    @key: "check_template_item"
    urlRoot: ->
      "/rest/check_templates/#{@check_template_id}/items"

  class exports.CheckTemplateItemList extends Stark.Collection
    model: exports.CheckTemplateItem
    @key: "check_template_items"
    url: -> "/rest/check_templates/#{@check_template_id}/items"
