{AncestorsMethods} = require '../../src/atom-utils'

describe 'AncestorsMethods mixin', ->
  [element, jasmineContent, DummyElement] = []

  class DummyElement extends HTMLElement
    AncestorsMethods.includeInto(this)

  DummyElement = document.registerElement 'dummy-element-ancestors', prototype: DummyElement.prototype

  beforeEach ->
    jasmineContent = document.body.querySelector('#jasmine-content')

    element = new DummyElement

    jasmineContent.appendChild(element)

  describe '::parents', ->
    it 'returns an array with all the ancestor node of the current element', ->
      parents = element.parents()
      expect(parents.length).toEqual(3)
      expect(parents[0]).toEqual(jasmineContent)
      expect(parents[1]).toEqual(document.body)

    describe 'when called with a selector', ->
      it 'returns the parents filtered using the selector', ->
        parents = element.parents('body')
        expect(parents.length).toEqual(1)
        expect(parents[0]).toEqual(document.body)
