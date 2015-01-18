Mixin = require 'mixto'
{Disposable} = require 'event-kit'

module.exports =
class DisposableEvents extends Mixin
  addDisposableEventListener: (object, event, listener) ->
    object.addEventListener event, listener
    new Disposable -> object.removeEventListener event, listener
