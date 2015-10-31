Mixin = require 'mixto'
{deprecate} = require 'grim'

debounce = (func, wait, immediate) ->
  timeout = undefined
  return ->
    context = this
    args = arguments

    later = ->
      timeout = null
      func.apply(context, args) unless immediate

    callNow = immediate and not timeout
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
    func.apply(context, args) if callNow

module.exports =
class ResizeDetection extends Mixin
  @includeInto: (cls) ->
    deprecate("ResizeDetection will be removed in future version. Use atom.views.pollDocument instead.")
    Mixin.includeInto.call(this, cls)

  domPollingInterval: 100
  domPollingIntervalId: undefined
  domPollingPaused: false

  initializeDOMPolling: ->
    @domPollingIntervalId = setInterval((=> @pollDOM()), @domPollingInterval)
    @previousDOMWidth = @clientWidth
    @previousDOMHeight = @clientHeight

  disposeDOMPolling: ->
    clearInterval(@domPollingIntervalId)
    @domPollingIntervalId = undefined

  pollDOM: ->
    return if @isDOMPollingPrevented()

    if @previousDOMWidth isnt @clientWidth or @previousDOMHeight isnt @clientHeight
      @previousDOMWidth = @clientWidth
      @previousDOMHeight = @clientHeight
      @resizeDetected(@previousDOMWidth, @previousDOMHeight)

  pauseDOMPolling: ->
    @domPollingPaused = true
    @resumeDOMPollingAfterDelay ?= debounce(@resumeDOMPolling, 100)
    @resumeDOMPollingAfterDelay()

  resumeDOMPolling: ->
    @domPollingPaused = false

  resumeDOMPollingAfterDelay: null

  isDOMPollingPrevented: -> @domPollingPaused

  resizeDetected: (width, height) ->
