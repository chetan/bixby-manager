
# Check whether the given element is visible in the current viewport
#
# via: http://stackoverflow.com/questions/487073/check-if-element-is-visible-after-scrolling#488073
#
# @param [Element] el
# @param [Boolean] partial          Whether or not to test for partial visibility (default: false)
#
# @return [Boolean] true if element is visible
_.isScrolledIntoView = (el, partial) ->
  docViewTop = $(window).scrollTop()
  docViewBottom = docViewTop + $(window).height()

  elTop = $(el).offset().top
  elBottom = elTop + $(el).height()

  if partial
    # check if the element is partially visible
    return ((elTop < docViewBottom && elTop > docViewTop) || (elBottom > docViewTop && elBottom < docViewBottom))

  else
    # check if the entire element is visible
    return ((elBottom <= docViewBottom) && (elTop >= docViewTop))

# Create a font-awesome icon
#
# @param [String] icon        icon name (without fa-)
# @param [String] clazz       extra classes to add to icon
#
# @return [String] icon html, e.g., <i class="fa fa-circle"></i>
_.icon = (icon, clazz) ->
  icon = icon.trim()
  c = "fa fa-#{icon}"
  if clazz?
    c += " " + clazz
  "<i class='#{c}'></i>"

# Toggle a class on the given element, e.g., remove if present, else add
_.toggleClass = (el, clazz) ->
  btn = $(el)
  if btn.hasClass(clazz)
    btn.removeClass(clazz)
  else
    btn.addClass(clazz)


# Add disabled class to given el
_.disable = (el) ->
  $(el).addClass("disabled")

# Remove disabled class from given el
_.enable = (el) ->
  $(el).removeClass("disabled")

# Dim the given element
_.dim = (el) ->
  if !el.length?
    el = $(el)
  el[0]._bg_color = el.css("background-color")
  el.css({"background-color": "black", "opacity": 0.3})

# Undim the given element
_.undim = (el) ->
  if !el.length?
    el = $(el)
  el.css({"background-color": el[0]._bg_color, "opacity": 1})

# Convert the given JSON string into a pretty-printed <pre> block
# via http://stackoverflow.com/a/7220510
_.prettyJSON = (json) ->
  obj = if _.isString(json)
    JSON.parse(json)
  else
    json
  json = JSON.stringify(obj, undefined, 2)
  json = json.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  json = json.replace /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, (match) ->
    cls = "number"
    if /^"/.test(match)
      if /:$/.test(match)
        cls = "key"
      else
        cls = "string"
    else if /true|false/.test(match)
      cls = "boolean"
    else cls = "null"  if /null/.test(match)
    "<span class=\"" + cls + "\">" + match + "</span>"

  return "<pre class='prettyjson'>" + json + "</pre>"

# Responsive helpers
_.is_xs = ->
  $(window).width() < 768

_.is_sm = ->
  $(window).width() >= 768 && $(window).width() < 992

_.is_md = ->
  $(window).width() >= 992 && $(window).width() < 1200

_.is_lg = ->
  $(window).width() >= 1200
