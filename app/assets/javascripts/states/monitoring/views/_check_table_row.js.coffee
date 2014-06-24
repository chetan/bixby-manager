namespace "Bixby.view.monitoring", (exports, top) ->

  class exports.CheckTableRow extends Stark.Partial

    template: "monitoring/_check_table_row"

    events:
      "click #delete_check": (e) ->
        v = @
        @check.destroy success: (model, response) ->
          console.log this
          v.parent.redraw()
      "click a.edit": ->
      	@log "hi", @
      	@check_editor.show() # TODO load options here

    post_render: ->
    	@log "post_render"
    	super
    	@check_editor ||= @partial(exports.CheckEditor, { check: @check, host: @host, hosts: @hosts })
    	@
