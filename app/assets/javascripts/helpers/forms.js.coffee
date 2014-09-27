
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

# Execute the given callback only when unique inputs are seen
#
# This is useful when binding a keyup event on an input to avoid firing multiple
# times on the same input value. Debouncing alone does not fix multiple fires here.
#
# @example
#
# "keyup input": _.debounceR 200, (e) ->
#   _.unique_val e.target, (val) =>
#     console.log(val)
#
#
# @param [Element] el
# @param [Function] cb
_.unique_val = (el, cb) ->
  el = $(el)
  last = el.data("last_input")
  val = _.val(el)
  if last != val
    el.data("last_input", val)
    cb.call(this, val)

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
_.toggle_valid_input = (el, msg, valid, clear) ->
  msg ||= ""

  if _.isString(el)
    if el.lastIndexOf(".") >= 0
      el = el.substr(el.lastIndexOf(".")+1)
    valid_div = "div.valid.#{el}"
    icon_span = "span.form-control-feedback.#{el}"
  else
    valid_div = el
    icon_span = null

  p = $(valid_div).parent()
  if !(p[0].nodeName == "DIV" && p.hasClass("has-feedback"))
    p = null

  # clear all validations
  if clear
    $(valid_div).removeClass("pass fail").html("")
    $(icon_span).removeClass("fa fa-check fa-times") if icon_span
    p.removeClass("has-success has-error has-warning") if p
    return


  # set validations
  if valid
    c = [ "fa fa-check", "fa-times", "pass", "fail", "has-success", "has-error" ]
  else
    c = [ "fa fa-times", "fa-check", "fail", "pass", "has-error", "has-success" ]

  if icon_span
    $(icon_span).addClass(c.shift()).removeClass(c.shift())
  else
    c.shift(); c.shift()

  $(valid_div).addClass(c.shift()).removeClass(c.shift()).html(msg)
  p.addClass(c.shift()).removeClass(c.shift()) if p

_.clear_valid_input = (el) ->
  _.toggle_valid_input(el, null, null, true)
