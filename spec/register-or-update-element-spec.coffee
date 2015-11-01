registerOrUpdateElement = require '../src/register-or-update-element'

describe 'registerOrUpdateElement', ->
  it 'registers a custom elements when it has not been registered yet', ->
    class Dummy
      createdCallback: ->
        @name = 'dummy'

    registerOrUpdateElement('dummy-element', Dummy.prototype)

    dummy = document.createElement('dummy-element')

    expect(dummy.name).toEqual('dummy')

  it 'updates the prototype of an already registered element', ->
    class Dummy
      createdCallback: ->
        @name = 'dummy'

    class Dummy2
      createdCallback: ->
        @name = 'dummy2'

    registerOrUpdateElement('dummy-element-2', Dummy.prototype)
    registerOrUpdateElement('dummy-element-2', Dummy2.prototype)

    dummy = document.createElement('dummy-element-2')

    expect(dummy.name).toEqual('dummy2')
