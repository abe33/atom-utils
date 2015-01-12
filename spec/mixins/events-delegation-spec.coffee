EventsDelegation = require '../../lib/mixins/events-delegation'
{click} = require '../helpers/events'

class DummyNode extends HTMLElement
  EventsDelegation.includeInto(this)

  createdCallback: ->
    @initializeContent()

  initializeContent: ->
    @appendChild(document.createElement('div'))
    @appendChild(document.createElement('span'))
    @appendChild(document.createElement('input'))

DummyNode = document.registerElement 'dummy-node', prototype: DummyNode.prototype

describe 'EventsDelegation', ->
  [element, jasmineContent, rootClickSpy, childClickSpy, childElement] = []

  beforeEach ->
    jasmineContent = document.body.querySelector('#jasmine-content')

    element = new DummyNode

    jasmineContent.appendChild(element)

  describe 'defining an event listener on the custom element', ->
    beforeEach ->
      rootClickSpy = jasmine.createSpy('root click')
      element.subscribeTo element, click: rootClickSpy

    it 'calls the listener when the element is clicked', ->
      click(element)

      expect(rootClickSpy).toHaveBeenCalled()

    describe 'when another click listener is registered on a child', ->
      beforeEach ->
        childElement = element.querySelector('div')

      it 'calls the child listener and the parent listener', ->
        childClickSpy = jasmine.createSpy('child click')
        element.subscribeTo element, 'div', click: childClickSpy

        click(childElement)

        expect(childClickSpy).toHaveBeenCalled()
        expect(rootClickSpy).toHaveBeenCalled()

      describe 'when the child listener stops the event propagation', ->
        beforeEach ->
          childClickSpy = jasmine.createSpy('child click').andCallFake (e) ->
            e.stopPropagation()

          element.subscribeTo element, 'div', click: childClickSpy

        it 'does not call the parent listener', ->
          click(childElement)

          expect(childClickSpy).toHaveBeenCalled()
          expect(rootClickSpy).not.toHaveBeenCalled()
