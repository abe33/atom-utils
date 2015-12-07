registerOrUpdateElement = require '../src/register-or-update-element'

describe 'registerOrUpdateElement', ->
  it 'registers a custom elements when it has not been registered yet', ->
    class Dummy
      createdCallback: ->
        @name = 'dummy'

    registerOrUpdateElement('dummy-element', Dummy.prototype)

    dummy = document.createElement('dummy-element')

    expect(dummy.name).toEqual('dummy')

  it 'preserves static methods', ->
    class StaticDummy
      @staticMethod: -> 'dummy'

    NewDummyClass = registerOrUpdateElement('static-dummy-element', class: StaticDummy)

    expect(NewDummyClass.staticMethod()).toEqual('dummy')

  it 'registers a custom element even when the class was create by babel', ->
    BabelDummy = require './fixtures/babel-dummy'

    registerOrUpdateElement('babel-dummy-element', BabelDummy.prototype)

    dummy = document.createElement('babel-dummy-element')

    expect(dummy.name).toEqual('dummy')

  it 'updates the prototype of an already registered element', ->
    class Dummy
      createdCallback: ->
        @name = 'dummy'

      update: ->
        @name = 'updated dummy'

    class Dummy2
      createdCallback: ->
        @name = 'dummy2'

      update: ->
        @name = 'updated dummy2'

    Dummy = registerOrUpdateElement('dummy-element-2', Dummy.prototype)

    dummy = document.createElement('dummy-element-2')
    expect(dummy.name).toEqual('dummy')

    dummy.update()
    expect(dummy.name).toEqual('updated dummy')

    Dummy = registerOrUpdateElement('dummy-element-2', Dummy2.prototype)

    dummy = document.createElement('dummy-element-2')
    expect(dummy.name).toEqual('dummy2')

    dummy.update()
    expect(dummy.name).toEqual('updated dummy2')
