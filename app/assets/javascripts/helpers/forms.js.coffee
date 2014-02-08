
# Retrieve the value of the given [input] element. Properly handles checkboxes
_.val = (el) ->
  if el.length
    el = $(el[0])
  else
    el = $(el)

  if el.prop("type") == "checkbox"
    return el.prop("checked")
  else
    return el.val()

# Select the text in the given input control when clicked
#
# Usage:
#
#   events:
#     "focusin input.install": _.select_text
#
_.select_text = (e) ->
  $(e.target).mouseup (e) ->
    setTimeoutR 0, ->
      e.target.select()
    $(this).unbind()

  setTimeoutR 0, ->
    e.target.select()

