'use strict'

# Original Route/Router implementation from Chaplin
# https://github.com/chaplinjs/chaplin

# Copyright (C) 2012 Moviepilot GmbH, 9elements GmbH et al.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

window.Stark or= {}

# This class does not inherit from Backbone’s router
class Stark.Router

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "router"

  constructor: ->
    Backbone.history or= new Backbone.History

  start: ->
    @log "starting history"
    return Backbone.history.start({ pushState: true })

  # Connect an address with a particular state
  # Directly creates a Backbone.history route
  match: (pattern, target, options = {}) ->
    # console.debug 'Router#match', pattern, target

    # Create a route
    route = new Stark.Route pattern, target, options
    route.app = @app
    # console.debug 'created route', route

    # Register the route at the Backbone History instance
    Backbone.history.route(route, route.handler)

    return route

  # Route a given URL path manually, return whether a route matched
  route: (path) =>
    #console.debug 'Router#route', path, params
    # Remove leading hash or slash
    path = path.replace /^(\/#|\/)/, ''
    for handler in Backbone.history.handlers
      if handler.route.test(path)
        handler.callback path, changeURL: true
        return true
    return false

  # Change the current URL, add a history entry.
  # Do not trigger any routes (which is Backbone’s
  # default behavior, but added for clarity)
  changeURL: (url) ->
    #console.debug 'Router#navigate', url
    Backbone.history.navigate url, trigger: false
