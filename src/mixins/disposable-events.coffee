Mixin = require 'mixto'
{Disposable} = require 'atom'

module.exports =
class DisposableEvents extends Mixin
  addDisposableEventListener: (object, event, listener, options) ->
    object.addEventListener event, listener, options
    new Disposable -> object.removeEventListener event, listener
