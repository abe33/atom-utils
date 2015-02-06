{ResizeDetection} = require '../../src/atom-utils'

describe 'ResizeDetection mixin', ->
  [element, jasmineContent, DummyElement] = []

  class DummyElement extends HTMLElement
    ResizeDetection.includeInto(this)

    attachedCallback: -> @initializeDOMPolling()
    detachedCallback: -> @disposeDOMPolling()

  DummyElement = document.registerElement 'dummy-element-resize', prototype: DummyElement.prototype

  beforeEach ->
    jasmine.Clock.useMock()

    jasmineContent = document.body.querySelector('#jasmine-content')

    element = new DummyElement
    element.style.display = 'block'
    expect(element.domPollingIntervalId).toBeUndefined()

    spyOn(element, 'resizeDetected')

    jasmineContent.appendChild(element)

  afterEach ->
    jasmine.Clock.defaultFakeTimer.reset()

  it 'starts the DOM polling interval when attached', ->
    expect(element.domPollingIntervalId).toBeDefined()

  it 'does not call the resizeDetected hook when the size does not change', ->
    jasmine.Clock.tick(101)
    expect(element.resizeDetected).not.toHaveBeenCalled()

  describe 'when the element size is changed', ->
    beforeEach ->
      element.style.width = '200px'
      element.style.height = '200px'
      jasmine.Clock.tick(101)

    it 'detects the change and call the resizeDetected hook', ->
      expect(element.resizeDetected).toHaveBeenCalledWith(200, 200)

  describe 'when detached from the DOM', ->
    it 'clear the DOM polling interval', ->
      jasmineContent.removeChild(element)

      expect(element.domPollingIntervalId).toBeUndefined()

  describe 'when paused', ->
    beforeEach ->
      element.pauseDOMPolling()
      element.style.width = '200px'
      element.style.height = '200px'
      jasmine.Clock.tick(101)

    it 'does not perform the DOM check', ->
      expect(element.resizeDetected).not.toHaveBeenCalled()
      expect(element.previousDOMWidth).not.toEqual(200)
      expect(element.previousDOMHeight).not.toEqual(200)

    describe 'and then resumed', ->
      beforeEach ->
        element.resumeDOMPolling()
        jasmine.Clock.tick(101)

      it 'detects the change and call the resizeDetected hook', ->
        expect(element.resizeDetected).toHaveBeenCalledWith(200, 200)
