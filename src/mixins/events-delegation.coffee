Mixin = require 'mixto'
DisposableEvents = require './disposable-events'
{Disposable, CompositeDisposable} = require 'event-kit'
eachPair = (object, callback) -> callback(k,v) for k,v of object

NO_SELECTOR = '__NONE__'

module.exports =
class EventsDelegation extends Mixin
  DisposableEvents.includeInto(this)

  subscribeTo: (object, selector, events) ->
    unless object instanceof HTMLElement
      [object, selector, events] = [this, object, selector]

    [events, selector] = [selector, NO_SELECTOR] if typeof selector is 'object'

    @eventsMap ?= new WeakMap
    @disposablesMap ?= new WeakMap
    @eventsMap.set(object, {}) unless @eventsMap.get(object)?
    @disposablesMap.set(object, {}) unless @disposablesMap.get(object)?

    eventsForObject = @eventsMap.get(object)
    disposablesForObject = @disposablesMap.get(object)

    eachPair events, (event, callback) =>
      unless eventsForObject[event]?
        eventsForObject[event] = {}
        disposablesForObject[event] = @createEventListener(object, event)

      eventsForObject[event][selector] = callback

    new Disposable => @unsubscribeFrom object, selector, events

  unsubscribeFrom: (object, selector, events) ->
    unless object instanceof HTMLElement
      [object, selector, events] = [this, object, selector]

    [events, selector] = [selector, NO_SELECTOR] if typeof selector is 'object'

    return unless eventsForObject = @eventsMap.get(object)

    for event of events
      delete eventsForObject[event][selector]

      if Object.keys(eventsForObject[event]).length is 0
        disposablesForObject = @disposablesMap.get(object)
        disposablesForObject[event].dispose()
        delete disposablesForObject[event]
        delete eventsForObject[event]

    if Object.keys(eventsForObject).length is 0
      @eventsMap.delete(object)
      @disposablesMap.delete(object)

  createEventListener: (object, event) ->
    listener = (e) =>
      return unless eventsForObject = @eventsMap.get(object)?[event]

      {target} = e
      @decorateEvent(e)

      @eachSelectorFromTarget(e, target, eventsForObject)
      eventsForObject[NO_SELECTOR]?(e) unless e.isPropagationStopped
      return true

    @addDisposableEventListener object, event, listener

  eachSelectorFromTarget: (event, target, eventsForObject) ->
    @nodeAndItsAncestors target, (node) =>
      return if event.isPropagationStopped
      @eachSelector eventsForObject, (selector,callback) =>
        matched = @targetMatch(node, selector)
        return if event.isImmediatePropagationStopped or not matched
        callback(event)

  eachSelector: (eventsForObject, callback) ->
    keys = Object.keys(eventsForObject)
    if keys.indexOf(NO_SELECTOR) isnt - 1
      keys.splice(keys.indexOf(NO_SELECTOR), 1)
    keys.sort (a,b) -> b.split(' ').length - a.split(' ').length

    for key in keys
      return true if callback(key, eventsForObject[key])
    return false

  targetMatch: (target, selector) ->
    return true if target.matches(selector)

    parent = target.parentNode
    while parent? and parent.matches?
      return true if parent.matches(selector)
      parent = parent.parentNode

    false

  nodeAndItsAncestors: (node, callback) ->
    parent = node.parentNode

    callback(node)
    while parent? and parent.matches?
      callback(parent)
      parent = parent.parentNode

  decorateEvent: (e) ->
    overriddenStop =  Event::stopPropagation
    e.stopPropagation = ->
      @isPropagationStopped = true
      overriddenStop.apply(this, arguments)

    overriddenStopImmediate =  Event::stopImmediatePropagation
    e.stopImmediatePropagation = ->
      @isImmediatePropagationStopped = true
      overriddenStopImmediate.apply(this, arguments)
