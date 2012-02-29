
# Helper functions to be loaded first

# # namespace Usage:
# #
# namespace 'Hello.World', (exports) ->
#   # `exports` is where you attach namespace members
#   exports.hi = -> console.log 'Hi World!'

# namespace 'Say.Hello', (exports, top) ->
#   # `top` is a reference to the main namespace
#   exports.fn = -> top.Hello.World.hi()

# Say.Hello.fn()  # prints 'Hi World!'

window.namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

namespace 'Bixby.model', (exports, top) ->
namespace 'Bixby.data', (exports, top) ->
namespace 'Bixby.view', (exports, top) ->
namespace 'Bixby.tmpl', (exports, top) ->

namespace 'Bixby', (exports, top) ->
  class exports.Router extends Backbone.Router
    routes: {}

  exports.router = new Bixby.Router
