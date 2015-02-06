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
    it 'returns an array with all the ancestor nodes of the current element', ->
      parents = element.parents()
      expect(parents.length).toEqual(3)
      expect(parents[0]).toEqual(jasmineContent)
      expect(parents[1]).toEqual(document.body)

    describe 'when called with a selector', ->
      it 'returns the parents filtered using the selector', ->
        parents = element.parents('body')
        expect(parents.length).toEqual(1)
        expect(parents[0]).toEqual(document.body)

  describe '::queryParentSelectorAll', ->
    it 'throws an error when no selector is passed', ->
      expect(-> element.queryParentSelectorAll()).toThrow()

    describe 'when called with a selector', ->
      it 'returns the parents filtered using the selector', ->
        parents = element.queryParentSelectorAll('body')
        expect(parents.length).toEqual(1)
        expect(parents[0]).toEqual(document.body)

  describe '::queryParentSelector', ->
    it 'throws an error when no selector is passed', ->
      expect(-> element.queryParentSelector()).toThrow()

    describe 'when called with a selector', ->
      it 'returns the parents filtered using the selector', ->
        body = element.queryParentSelector('body')
        expect(body).toEqual(document.body)

      it 'returns undefined when no parent match the selector', ->
        node = element.queryParentSelector('node')
        expect(node).toBeUndefined()
