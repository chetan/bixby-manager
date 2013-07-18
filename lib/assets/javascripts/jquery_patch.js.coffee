
# adapted from http://forum.jquery.com/topic/jquery-invoke-customized-each-method-with-custom-context-params-order

# $.each with context as the first parameter
#
# @param [Context] context              applied this
# @param [Array|Object] elements        list of elements to iterate
# @param [Function] func                function with arguments(index, Element)
#
# @return [Object]
# @see $.each
$.eachR = (context, elements, func) ->
  return $.each(elements, $.proxy(func, context))

# $.fn.each with context as the first parameter
#
# @param [Context] context              applied this
# @param [Function] func                function with arguments(index, Element)
#
# @return [jQuery]
# @see .each
$.fn.eachR = (context, func) ->
  return $.eachR(context, this, func, context, true)
