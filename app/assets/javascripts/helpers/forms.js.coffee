
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

# Mark given element as passing
_.pass = (el, msg) ->
  _.toggle_valid_input(el, msg, true)

# Mark given element as failing
_.fail = (el, msg) ->
  _.toggle_valid_input(el, msg, false)

# Toggle pass/fail of the given input
_.toggle_valid_input = (el, msg, valid) ->
  msg ||= ""

  if _.isString(el)
    if el.lastIndexOf(".") >= 0
      el = el.substr(el.lastIndexOf(".")+1)
    valid_div = "div.valid.#{el}"
    icon_span = "span.form-control-feedback.#{el}"
  else
    valid_div = el
    icon_span = null

  if valid
    c = [ "fa fa-check", "fa-times", "pass", "fail", "has-success", "has-error" ]
  else
    c = [ "fa fa-times", "fa-check", "fail", "pass", "has-error", "has-success" ]

  if icon_span
    $(icon_span).addClass(c.shift()).removeClass(c.shift())
  else
    c.shift(); c.shift()

  $(valid_div).addClass(c.shift()).removeClass(c.shift()).html(msg)

  p = $(valid_div).parent()
  if p[0].nodeName == "DIV" && p.hasClass("has-feedback")
    p.addClass(c.shift()).removeClass(c.shift())
