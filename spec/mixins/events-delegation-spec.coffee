{EventsDelegation} = require '../../lib/atom-utils'
{click} = require '../helpers/events'

class DummyNode extends HTMLElement
  EventsDelegation.includeInto(this)

  createdCallback: ->
    @initializeContent()

  initializeContent: ->
    @appendChild(document.createElement('div'))
    @firstChild.className = 'foo'

    @firstChild.appendChild(document.createElement('span'))
    @appendChild(document.createElement('input'))

DummyNode = document.registerElement 'dummy-node', prototype: DummyNode.prototype

describe 'EventsDelegation', ->
  [element, jasmineContent, rootClickSpy, childClickSpy, childClickSpy2, inputClickSpy, childElement, rootDisposable, inputDisposable] = []

  beforeEach ->
    jasmineContent = document.body.querySelector('#jasmine-content')

    element = new DummyNode

    jasmineContent.appendChild(element)

  describe 'defining an event listener on the custom element', ->
    beforeEach ->
      rootClickSpy = jasmine.createSpy('root click')
      inputClickSpy = jasmine.createSpy('input click')
      rootDisposable = element.subscribeTo click: rootClickSpy
      inputDisposable = element.subscribeTo 'input', click: inputClickSpy

    it 'calls the listener when the element is clicked', ->
      click(element)

      expect(rootClickSpy).toHaveBeenCalled()

    it 'does not call a listener whose selector does not match', ->
      click(element)

      expect(inputClickSpy).not.toHaveBeenCalled()

    it 'returns a disposable that can be used to unsubscribe from the events', ->
      expect(rootDisposable).toBeDefined()
      expect(inputDisposable).toBeDefined()

      rootDisposable.dispose()

      click(element)
      expect(rootClickSpy).not.toHaveBeenCalled()

      inputDisposable.dispose()

      click(element.querySelector('input'))
      expect(inputClickSpy).not.toHaveBeenCalled()

    it 'clean up the object listeners when there is no more listeners', ->
      expect(Object.keys(element.eventsMap.get(element)['click']).length).toEqual(2)

      rootDisposable.dispose()

      expect(Object.keys(element.eventsMap.get(element)).length).toEqual(1)
      expect(Object.keys(element.eventsMap.get(element)['click']).length).toEqual(1)

      inputDisposable.dispose()

      expect(element.eventsMap.get(element)).toBeUndefined()

    describe 'when two selectors matches the same node', ->
      beforeEach ->
        childElement = element.querySelector('div')

      it 'calls both listeners', ->
        childClickSpy = jasmine.createSpy('child click')
        childClickSpy2 = jasmine.createSpy('child click 2')

        element.subscribeTo 'div', click: childClickSpy
        element.subscribeTo '.foo', click: childClickSpy2

        click(childElement)

        expect(childClickSpy).toHaveBeenCalled()
        expect(childClickSpy2).toHaveBeenCalled()

      describe 'when the first listener stop the immediate propagation', ->
        it 'does not call the second listener', ->
          childClickSpy = jasmine.createSpy('child click').andCallFake (e) ->
            e.stopImmediatePropagation()
          childClickSpy2 = jasmine.createSpy('child click 2')

          element.subscribeTo 'div', click: childClickSpy
          element.subscribeTo '.foo', click: childClickSpy2

          click(childElement)

          expect(childClickSpy).toHaveBeenCalled()
          expect(childClickSpy2).not.toHaveBeenCalled()

    describe 'when another click listener is registered on a child', ->
      beforeEach ->
        childElement = element.querySelector('div')

      it 'calls the child listener and the parent listener', ->
        childClickSpy = jasmine.createSpy('child click')
        element.subscribeTo 'div', click: childClickSpy

        click(childElement)

        expect(childClickSpy).toHaveBeenCalled()
        expect(rootClickSpy).toHaveBeenCalled()

      it 'does not call a listener whose selector does not match', ->
        click(childElement)

        expect(inputClickSpy).not.toHaveBeenCalled()

      describe 'when the child listener stops the event propagation', ->
        beforeEach ->
          childClickSpy = jasmine.createSpy('child click').andCallFake (e) ->
            e.stopPropagation()

          element.subscribeTo 'div', click: childClickSpy

        it 'does not call the parent listener', ->
          click(childElement)

          expect(childClickSpy).toHaveBeenCalled()
          expect(rootClickSpy).not.toHaveBeenCalled()

      describe 'and on a child of the child', ->
        [deepChildElement, deepChildClickSpy] = []

        describe 'without stopping the propagation', ->
          beforeEach ->
            deepChildElement = childElement.querySelector('span')

            childClickSpy = jasmine.createSpy('child click')
            deepChildClickSpy = jasmine.createSpy('deep child click')

            element.subscribeTo 'div', click: childClickSpy
            element.subscribeTo 'span', click: deepChildClickSpy

          it 'calls all the listeners', ->
            click(deepChildElement)

            expect(rootClickSpy).toHaveBeenCalled()
            expect(childClickSpy).toHaveBeenCalled()
            expect(deepChildClickSpy).toHaveBeenCalled()
