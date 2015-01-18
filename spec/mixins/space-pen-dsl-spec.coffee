SpacePenDSL = require '../../src/mixins/space-pen-dsl'

class DummyElement extends HTMLElement
  SpacePenDSL.includeInto(this)

  @content: ->
    @div outlet: 'main', class: 'foo', =>
      @tag 'span', outlet: 'span', class: 'bar'

  createdCallback: ->
    @created = true

DummyElement = document.registerElement 'dummy-element', prototype: DummyElement.prototype

describe 'space-pen DSL', ->
  [element] = []

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
