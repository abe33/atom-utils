{SpacePenDSL, registerOrUpdateElement} = require '../../src/atom-utils'

describe 'space-pen DSL', ->
  [element, DummyElement] = []

  class DummyElement extends HTMLElement
    SpacePenDSL.includeInto(this)

    @content: ->
      @div outlet: 'main', class: 'foo', =>
        @tag 'span', outlet: 'span', class: 'bar'

    createdCallback: ->
      @created = true

  DummyElement = registerOrUpdateElement 'dummy-element-dsl', DummyElement.prototype

  beforeEach ->
    element = new DummyElement

  it 'creates a DOM structure based on the @content method', ->
    expect(element.querySelector('div')).toExist()
    expect(element.querySelector('div span')).toExist()

  it 'creates a property for each outlet', ->
    expect(element.main).toEqual(element.querySelector('div'))
    expect(element.span).toEqual(element.querySelector('div span'))

  it 'calls the createdCallback method defined on the element', ->
    expect(element.created).toBeTruthy()

  it 'sets the proper attribtues on created elements', ->
    expect(element.main.className).toEqual('foo')
    expect(element.span.className).toEqual('bar')

  describe 'with shadow root enabled', ->
    class ShadowDummyElement extends HTMLElement
      SpacePenDSL.includeInto(this)

      @useShadowRoot()

      @content: ->
        @div outlet: 'main', class: 'foo', =>
          @tag 'span', outlet: 'span', class: 'bar'

      createdCallback: ->
        @created = true

    ShadowDummyElement = registerOrUpdateElement 'shadow-dummy-element-dsl', ShadowDummyElement.prototype

    beforeEach ->
      element = new ShadowDummyElement

    it 'creates a shadow root for the element', ->
      expect(element.shadowRoot).toBeDefined()

    it 'creates a DOM structure based on the @content method', ->
      expect(element.shadowRoot.querySelector('div')).toExist()
      expect(element.shadowRoot.querySelector('div span')).toExist()

    it 'creates a property for each outlet', ->
      expect(element.main).toEqual(element.shadowRoot.querySelector('div'))
      expect(element.span).toEqual(element.shadowRoot.querySelector('div span'))
